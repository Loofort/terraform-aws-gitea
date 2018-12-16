
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}
variable "cidr_subnet" {
  description = "the cidr of the subnet"
  #default     = "0.0.0.0/0"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type = "map"
  #default     = {}
}
variable "az" {
  description = "availability zones in the region"
  default     = ""
}


# A computed default 
data "aws_availability_zones" "azs" {}
locals {
  default_az = "${data.aws_availability_zones.azs.names[0]}"
  az         = "${var.az != "" ? var.az : local.default_az}"
}

# Outputs
output "subnet" {
  value = "${aws_subnet.public.id}"
}
output "id" {
  value = "${aws_vpc.this.id}"
}