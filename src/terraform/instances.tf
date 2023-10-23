resource "yandex_compute_instance" "vm-1" {
  name        = "vm-1"
  hostname    = "vm-1"
  zone        = "ru-central1-a"
  description = "vm-1"
  platform_id = "standard-v2"

  resources {
    cores     = 4
    memory    = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.image_id}"    ## Ubuntu 20.04 LTS
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data   = "${file("./user.txt")}"
    description = "The file includes the users to be added to the VM"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_compute_instance" "vm-2" {
  name        = "vm-2"
  hostname    = "vm-2"
  zone        = "ru-central1-b"
  description = "vm-2"
  platform_id = "standard-v2"

  resources {
    cores     = 4
    memory    = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.image_id}"    ## Ubuntu 20.04 LTS
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
  }

  metadata = {
    user-data   = "${file("./user.txt")}"
    description = "The file includes the users to be added to the VM"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "yandex_compute_instance" "vm-3" {
  name        = "vm-3"
  hostname    = "vm-3"
  zone        = "ru-central1-c"
  description = "vm-3"
  platform_id = "standard-v2"

  resources {
    cores     = 4
    memory    = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.image_id}"    ## Ubuntu 20.04 LTS
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = true
  }

  metadata = {
    user-data   = "${file("./user.txt")}"
    description = "The file includes the users to be added to the VM"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "yandex_compute_instance" "ansible" {
  name        = "ansible"
  hostname    = "ansible"
  zone        = "ru-central1-a"
  description = "ansible"
  platform_id = "standard-v2"

  resources {
    cores     = 4
    memory    = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.image_id}"    ## Ubuntu 20.04 LTS
      type        = "network-nvme"
      size        = "30"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ansible.id
    nat       = true
  }

  metadata = {
    user-data   = "${file("./user.txt")}"
    description = "The file includes the users to be added to the VM"
  }

  lifecycle {
    create_before_destroy = true
  }
}