variable "storage_service_account_name" {
  type = string
}
variable "cluster_service_account_name" {
  type = string
}
variable "project_name" {
  type = string
}
variable "storage_name" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_region" {
  type = string
}
/*
* "enable_private_cluster" borrowed from 2i2c; Cf.
* https://github.com/2i2c-org/infrastructure/pull/538/files
*/
variable "enable_private_cluster" {
  type        = bool
  default     = false
  description = <<-EOT
  Deploy the kubernetes cluster into a private subnet

  By default, GKE gives each of your nodes a public IP & puts them in a public
  subnet. When this variable is set to `true`, the nodes will be in a private subnet
  and not have public IPs. A cloud NAT will provide outbound internet access from
  these nodes. The kubernetes API will still be exposed publicly, so we can access
  it from our laptops & CD.
  
  This is often required by institutional controls banning VMs from having public IPs.
  EOT
}