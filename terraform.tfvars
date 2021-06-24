# vCloud Director Connection Variables

 vcd_user = ""

 vcd_url = ""
 #cpu number exactly shown in the onboarding sheet
 cpu_allocation = 8
 mem_allocation = 16
 vm_count = 0
 #Define the edge size - "compact, full ("Large"), x-large, full4 ("Quad Large")."
 edge_size = ""
 # based on tenant type and Customer name, names of ORG and VDC are decided, you can see that in variables file.
 cust_name = ""

 /*
 There are MAP created in variable file which map this tenant type to pvdc, nwpool, vcenter, cpu speed for tenant  and storage profile. Please modify those maps to reflect you enviroment
  NOTE - define the type of the tenant it is and acceptable values are below :  
DC1-ENT
DC1-BASIC
DC1-BASIC-POC 
DC1-ENT-POC 
DC2-ENT
DC2-ENT-POC
  */

  tenant_type = ""
  ext_netw = ""
  ext_vlan = ""
  vm_storage= ""
  catalog_storage = null
/* example for org network map :
{
  ON01 = "192.168.0.0/24"
  ON02 = "192.168.1.0/24"
  }

*/


  on_list = 


/* example for user map, you can add multiple users :
{ 
     user1 = {
     user_name = "userone"
     email = "abc@abc.com"
     }
     
  }

*/

  users = 

