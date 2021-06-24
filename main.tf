terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.1.0"
    }
  }
}






# Connect VMware vCloud Director Provider
provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_pass
  org                  = "System"
  url                  = var.vcd_url
  max_retry_timeout    = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}

#create external network

resource "vcd_external_network" "net" {
  for_each = local.instances_extnet
  name     = each.key
  #description = "Reference for vCD external network"

  ip_scope {
    gateway = each.value.ext_gw
    netmask = each.value.ext_mask


    static_ip_pool {
      start_address = each.value.ext_pool_start
      end_address   = each.value.ext_pool_end
    }
  }
  vsphere_network {
    name    = each.value.vc_pg_name
    type    = each.value.vc_net_type
    vcenter = each.value.vc
  }
}
#Create a new org names "T3"
resource "vcd_org" "org-name" {
  name      = local.org_name
  full_name = local.org_name
  #description      = "The pride of my work"
  is_enabled       = "true"
  delete_recursive = "true"
  delete_force     = "true"

  vapp_lease {
    maximum_runtime_lease_in_sec          = 0
    power_off_on_runtime_lease_expiration = false
    maximum_storage_lease_in_sec          = 0 # never expires
    delete_on_storage_lease_expiration    = false
  }
  vapp_template_lease {
    maximum_storage_lease_in_sec       = 0 # never expires
    delete_on_storage_lease_expiration = false
  }
  depends_on = [vcd_external_network.net]
}

#Create a new Organization Admin
resource "vcd_org_user" "org-admin" {
  for_each     =  var.users
  org           = local.org_name #variable referred in variable file 
  name          = lower(each.value.user_name)  #variable referred in variable file
  description   = var.org_admin_description
  role          = var.user_role
  password      = var.user_pwd
  enabled       = true
  email_address = each.value.email
  depends_on    = [vcd_org.org-name]
}

# Create Org VDC for above org
resource "vcd_org_vdc" "vdc-name" {
  name = local.vdc_name
  #description = "The pride of my work"
  org                        = local.org_name #variable referred in variable file
  allocation_model           = "Flex"
  elasticity                 = false
  include_vm_memory_overhead = false
  network_pool_name          = var.nwpool_list[var.tenant_type]
  provider_vdc_name          = var.pvdc_list[var.tenant_type]
  network_quota              = 100
  cpu_speed                  = var.cpuspeed_list[var.tenant_type]
  memory_guaranteed          = 0.50
  cpu_guaranteed             = 0.07
  vm_quota                   = var.vm_count
  compute_capacity {
    cpu {
      allocated = replace(var.tenant_type, "ENT", "") != var.tenant_type ? var.cpu_allocation * var.convert_cpu * var.multiply  : var.cpu_allocation * var.convert_cpu 
    }

    memory {
      allocated = var.mem_allocation * var.convert
    }
  }
  dynamic "storage_profile" {
    for_each =  { 
      for name, user in local.map : name => user
    if user.storage_allocation != null 
    }
    content {
      name    = storage_profile.key
      limit   = storage_profile.value.storage_allocation * var.convert
      default = storage_profile.value.is_default
    }
  }

  enabled                  = true
  enable_thin_provisioning = true
  enable_fast_provisioning = false
  delete_force             = true
  delete_recursive         = true
  depends_on               = [vcd_org.org-name]
}

resource "vcd_edgegateway" "egw" {
  org  = local.org_name #variable referred in variable file
  vdc  = local.vdc_name #variable referred in variable file
  name = local.edge_name
  #description             = "T3 new edge gateway"
  configuration       = var.edge_size
  distributed_routing = false
  external_network {
    name = element(keys(local.instances_extnet), 1)
    subnet {
      ip_address            = local.egw_ip
      gateway               = local.egw_gw
      netmask               = local.egw_mask
      use_for_default_route = true
    }
  }
  depends_on = [vcd_org_vdc.vdc-name]
}

resource "vcd_network_routed" "net" {
  for_each     =  var.on_list 
  
  /*{
    for name, user in local.instances_orgnet : name => user
    if user.orgnet_gw != null
  }
  */
  org          = local.org_name #variable referred in variable file
  vdc          = local.vdc_name #variable referred in variable file
  name         = "${var.cust_name}-${var.tenant_type}-${each.key}"
  edge_gateway = local.edge_name
  gateway      = cidrhost(each.value, 1)
  netmask      = cidrnetmask(each.value)
  static_ip_pool {
    start_address = cidrhost(each.value, 2)
    end_address   = cidrhost(each.value, -2)
  }
  depends_on = [vcd_edgegateway.egw]
}
