data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "vm" {
  count    = var.count_vm
  name     = "go-app-${count.index}"
  hostname = "catgpt-${count.index}"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
    docker-compose = file("${path.module}/docker-compose.yaml")

  }
}

#create target group
resource "yandex_lb_target_group" "catgpt-group" {
    name = "catgpt-group"
    target {
        subnet_id = var.vpc_subnet_id
        address = yandex_compute_instance.vm[0].network_interface.0.nat_ip_address
    }
    target {
        subnet_id = var.vpc_subnet_id
        address = yandex_compute_instance.vm[1].network_interface.0.nat_ip_address
    }
}

resource "yandex_lb_network_load_balancer" "internal-lb-test" {
  name = "internal-lb-test-2"
  type = "internal"
  listener {
    name        = "test-listener"
    port        = 80
    target_port = 8080
    protocol    = "tcp"
    internal_address_spec {
      subnet_id  = var.vpc_subnet_id
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.catgpt-group.id
    healthcheck {
      name                = "http"
      interval            = 100
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      http_options {
        port = 8080
        path = "/"
      }
    }
  }
}