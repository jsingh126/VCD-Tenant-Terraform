# Overview
This repo contains an example of how to create a Tenant in vCloud director. This example is customized for my own use case. However we can use this as a template and customized according to your environment.

## Below are few customization to have user enter few inputs as possible

### Codifying the naming conventions and autoselecting the variables.
User only has to enter the Customer name and "tenant_type". "tenant_type" is used for two things 
1. Generate the names for ORG, VDC, Edge and ORG network
2. This "tenant_type" value also maps to   "Provider VDC", "vCenterCenter", network pool, storage profile and cpu speed ( we used two different cpu speed 1000 mhz and 2000 mhz for different tenan_type). You can see this mapping in variables.tf. You can call this mapping or autoselecting the variables based on a single value.

````
## Names generation locals variables:
locals {
  org_name = "${var.cust_name}-${substr(var.tenant_type, 0, 3)}"
}

locals {
  vdc_name = "${var.cust_name}-${var.tenant_type}-VDC01"
}
locals {
  edge_name = "${var.cust_name}-${var.tenant_type}-EG01"
}

## Mapping Variables :

variable "pvdc_list"
variable "cpuspeed_list" 
variable "nwpool_list" 
variable "vc_list"
variable "sp_list" 
variable "csp_list"
```` 
### Using cidrhost and cidrnetmask function
By default in our onboarding sheet we get only the subnet address of org network and external network. From which we have to derive ip pool, gateway address etc which can be automated using Terraform "IP Network Functions" - cidrhost, cidrnetmask, cidrsubnet, cidrsubnets
For example, how to derive Edge gateway IP details :
```
locals {
  egw_ip = cidrhost(var.ext_netw, 2)
}

locals {
  egw_gw = cidrhost(var.ext_netw, 1)
}

locals {
  egw_mask = cidrnetmask(var.ext_netw)
}
```
https://www.terraform.io/docs/language/functions/cidrhost.html
https://www.terraform.io/docs/language/functions/cidrnetmask.html

