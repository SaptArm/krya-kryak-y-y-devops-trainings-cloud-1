variable "count_vm" {
    description = "count vm for app"
    type        = number
    default     = 1
}

variable "vpc_subnet_id" {
  description = "VPC subnet network id"
  type        = string
}

variable "ssh_credentials" {
  description = "Credentials for connect to instances"
  type        = object({
    user        = string
    private_key = string
    pub_key     = string
  })
  default     = {
    user        = "ubuntu"
    private_key = "~/.ssh/id_ed25519"
    pub_key     = "~/.ssh/id_ed25519.pub"
  }
}
