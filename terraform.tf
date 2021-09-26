terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = "4.45.0"
    }
  }
}

provider "oci" {
    tenancy_ocid     = "${var.tenancy_ocid}"
    user_ocid        = "${var.user_ocid}"
    region           = "${var.region}"
    fingerprint      = "${var.fingerprint}"
    private_key_path = "${var.private_key_path}"
}