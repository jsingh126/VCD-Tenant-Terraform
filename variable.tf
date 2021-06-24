

variable "vcd_pass" {
  type    = string
  sensitive   = true
}


variable "vcd_user" {
  description = "vCloud user"
  
}


variable "vcd_allow_unverified_ssl" {
  default = true
}


variable "vcd_url" {
  
}





variable "org_admin_description" {
  default = "Tenant Admin"
}
variable "user_role" {
  default = "Tenant Admin"
}
variable "user_pwd" {
  default = "123"

}

variable "vcd_max_retry_timeout" {
  default = 60
}


variable "cpu_allocation" {
  type    = number
  #default = 72
}

variable "multiply" {
  type = number
  default = 2
}


variable "mem_allocation" {
  type    = number
  #default = 144
}

variable "vm_count" {
  type = number
  #default = 0
}

#Define the edge size - "compact, full ("Large"), x-large, full4 ("Quad Large")."
variable "edge_size" {
 # default = "full"
}

variable "cust_name" {
  #default = ""
}

/*
  NOTE - define the type of the tenant it is and acceptable values are below :  
DC1-ENT
DC1-BASIC
DC1-BASIC-POC 
DC1-ENT-POC 
DC2-ENT
DC2-ENT-POC
  */
variable "tenant_type" {
  
}

variable "ext_netw" {
  
}

variable "ext_vlan" {
  
}


variable "vm_storage" {
  
  type = string
  
}

variable "catalog_storage" {
  
  type = string
}

variable "on_list" {
  type = map(any)

  #default = {
  #ON01 = 
  #}
}



variable "pvdc_list" {

  type = map(any)

  default = {
    DC1-ENT       = "DC1-Enterprise"
    DC1-ENT-POC   = "DC1-Enterprise"
    DC1-BASIC     = "DC1-Standard"
    DC1-BASIC-POC = "DC1-Standard"
    DC2-ENT       = "DC2-Enterprise"
    DC2-ENT-POC   = "DC2-Enterprise"
  }
}
variable "convert" {
  default = "1024"
}

variable "convert_cpu" {
  default = "1000"
}

variable "cpuspeed_list" {

  type = map(any)

  default = {
    DC1-ENT       = "2000"
    DC1-ENT-POC   = "1000"
    DC1-BASIC     = "1000"
    DC1-BASIC-POC = "1000"
    DC2-ENT       = "2000"
    DC2-ENT-POC   = "1000"
  }
}

variable "nwpool_list" {
  type = map(any)

  default = {
    DC1-ENT       = "DC1-RES-TZ1-01"
    DC1-BASIC-POC = "DC1-RES-TZ1-01"
    DC1-BASIC     = "DC1-RES-TZ1-01"
    DC1-ENT-POC   = "DC1-RES-TZ1-01"
    DC2-ENT       = "DC2-RES-TZ1-01"
    DC2-ENT-POC   = "DC2-RES-TZ1-01"

  }
}

variable "vc_list" {
  type = map(any)

  default = {
    DC1-ENT       = "DC1vcr01.mycloud.com"
    DC1-BASIC-POC = "DC1vcr01.mycloud.com"
    DC1-BASIC     = "DC1vcr01.mycloud.com"
    DC1-ENT-POC   = "DC1vcr01.mycloud.com"
    DC2-ENT       = "DC2vcr01.mycloud.com"
    DC2-ENT-POC   = "DC2vcr01.mycloud.com"
  }
}


locals {
  org_name = "${var.cust_name}-${substr(var.tenant_type, 0, 3)}"
}

locals {
  vdc_name = "${var.cust_name}-${var.tenant_type}-VDC01"
}
locals {
  edge_name = "${var.cust_name}-${var.tenant_type}-EG01"
}



locals {
  egw_ip = cidrhost(var.ext_netw, 2)
}

locals {
  egw_gw = cidrhost(var.ext_netw, 1)
}

locals {
  egw_mask = cidrnetmask(var.ext_netw)
}





locals {
  instances_extnet = {
    "${var.cust_name}-${var.tenant_type}-${var.ext_vlan}-EN01" = {
      ext_gw         = cidrhost(var.ext_netw, 1)
      ext_mask       = cidrnetmask(var.ext_netw)
      ext_pool_start = cidrhost(var.ext_netw, 2)
      ext_pool_end   = cidrhost(var.ext_netw, -2)
      vc             = var.vc_list[var.tenant_type]
      vc_net_type    = "DV_PORTGROUP"
      vc_pg_name     = "${var.cust_name}-${var.tenant_type}-VL${var.ext_vlan}"

    }


  }
}

variable "sp_list" {

  type = map(any)

  default = {
    DC1-ENT       = "DC1-Enterprise-Performance"
    DC1-ENT-POC   = "DC1-Enterprise-Performance"
    DC1-BASIC     = "DC1-Basic-Performance"
    DC1-BASIC-POC = "DC1-Basic-Performance"
    DC2-ENT       = "DC2-Enterprise-Performance"
    DC2-ENT-POC   = "DC2-Enterprise-Performance"
  }
}

variable "csp_list" {

  type = map(any)

  default = {
    DC1-ENT       = "DC1-Enterprise-Catalog"
    DC1-ENT-POC   = "DC1-Enterprise-Catalog"
    DC1-BASIC     = "DC1-Basic-Catalog"
    DC1-BASIC-POC = "DC1-Basic-Catalog"
    DC2-ENT       = "DC2-Enterprise-Catalog"
    DC2-ENT-POC   = "DC2-Enterprise-Catalog"
  }
}


locals {
  map = {
    var.sp_list[var.tenant_type] = {
      storage_allocation = var.vm_storage
      is_default         = "true"
    }
    var.csp_list[var.tenant_type] = {
      storage_allocation = var.catalog_storage
      is_default         = "false"
    }


  }
}

variable "users" {
  type = map(any)
  #default = {}
  }


