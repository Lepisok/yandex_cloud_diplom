terraform {
 required_providers {
   yandex = {
     source  = "yandex-cloud/yandex"
   }
 }
 required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "lepis-bucket"
    region     = "ru-central1"
    key        = "s3/terraform.tfstate"
    # access_key pulled from $YC_STORAGE_ACCESS_KEY
    # secret_key pulled from $YC_STORAGE_SECRET_KEY
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  cloud_id  = "b1gnbhah0meo1u27m3jf"
  folder_id = "${var.folder_id}"
  zone = "${var.zone}"
}