data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "vm" {
  count    = var.count_vm
  name     = "go-app-${count.index}"
  hostname = "catgpt-${count.index}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = 15
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }
}

#create target group
resource "yandex_lb_target_group" "catgpt-group" {
    name = "catgpt-group"
    count = var.count_vm
    target {
        subnet_id = var.vpc_subnet_id
        address = yandex_compute_instance.vm[count.index].network_interface.0.nat_ip_address
    }
  
}

# resource "yandex_lb_network_load_balancer" "balancer" {

#     name = "test-network-balancer"

# }