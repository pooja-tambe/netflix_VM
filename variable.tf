variable "RG_name" {
  type        = string
  description = "resurce grp name"
}

variable "location" {
  type        = string
  description = "resurce grp location"
}
variable "storage_name" {
  type        = string
  description = "resurce grp name"
}

variable "container" {
  type        = string
  description = "container for blob storage"
}

variable "vnet_name" {
  type        = string
  description = "Vnet name"
}
variable "subent_name" {
  type        = string
  description = "fronend vm subnet"
  default = "subnet"
}
variable "nic_name" {
  type        = string
  description = "nic name"
}
variable "vm" {

}

variable "size" {

}
variable "nsg_name" {
  
}