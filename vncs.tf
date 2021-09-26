resource "oci_core_vcn" "default" {
    compartment_id = var.compartment_ocid
    cidr_blocks    = var.vcn_cidr_blocks
    display_name   = var.vcn_display_name
    dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "default" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.default.id
    display_name   = "defaultInternetGateway"
}

resource "oci_core_default_route_table" "default" {
    manage_default_resource_id = oci_core_vcn.default.default_route_table_id
    display_name               = "defaultRouteTable"

    route_rules {
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.default.id
    }
}

resource "oci_core_default_dhcp_options" "default" {
    manage_default_resource_id = oci_core_vcn.default.default_dhcp_options_id
    display_name               = "defaultDhcpOptions"

    options {
        type        = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
    }

    options {
        type                = "SearchDomain"
        search_domain_names = var.vcn_search_paths
    }

}

resource "oci_core_default_security_list" "default" {
  manage_default_resource_id = oci_core_vcn.default.default_security_list_id
  display_name               = "defaultSecurityList"

  egress_security_rules {
      destination = "0.0.0.0/0"
      protocol    = "6"
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    protocol    = "6"
    stateless   = false
    tcp_options {
        min = 22
        max = 22
    }
  }

  # Allow all ingress connection from workstation
  ingress_security_rules {
    source      = var.vcn_home_ip_src
    protocol    = "all"
  }

}

resource "oci_core_subnet" "default" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.default.id
  cidr_block     = var.vcn_subnet_cidr_block
  display_name   = "default"
  dns_label      = "private"
}

// Unifi controller network security rule
resource "oci_core_network_security_group" "unifi" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.default.id
    display_name   = "unifi"
}

resource "oci_core_network_security_group_security_rule" "unifi_cc" {
    network_security_group_id = oci_core_network_security_group.unifi.id
    protocol                  = "6"
    direction                 = "INGRESS"
    source                    = var.vcn_unifi_devices_cidr
    source_type               = "CIDR_BLOCK"
    description               = "Device C&C"
    
    tcp_options {
        destination_port_range {
            min = 8080
            max = 8080
        }
    }
}
resource "oci_core_network_security_group_security_rule" "unifi_http" {
    network_security_group_id = oci_core_network_security_group.unifi.id
    protocol                  = "6"
    direction                 = "INGRESS"
    source                    = var.vcn_unifi_devices_cidr
    source_type               = "CIDR_BLOCK"
    description               = "HTTP portal"
    
    tcp_options {
        destination_port_range {
            min = 8880
            max = 8880
        }
    }
}
resource "oci_core_network_security_group_security_rule" "unifi_https" {
    network_security_group_id = oci_core_network_security_group.unifi.id
    protocol                  = "6"
    direction                 = "INGRESS"
    source                    = var.vcn_unifi_devices_cidr
    source_type               = "CIDR_BLOCK"
    description               = "HTTPS portal"
    
    tcp_options {
        destination_port_range {
            min = 8843
            max = 8843
        }
    }
}
resource "oci_core_network_security_group_security_rule" "unifi_stun" {
    network_security_group_id = oci_core_network_security_group.unifi.id
    protocol                  = "17"
    direction                 = "INGRESS"
    source                    = var.vcn_unifi_devices_cidr
    source_type               = "CIDR_BLOCK"
    description               = "STUN service"
    
    udp_options {
        destination_port_range {
            min = 3478
            max = 3478
        }
    }
}