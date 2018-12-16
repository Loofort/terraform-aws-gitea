################# inputs ################
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    Project = "gitea"
  }
}

# The backend and provider are configured by env variables
provider "aws" {}
terraform {
  backend "s3" {}
}

############## outputs #################

output "amazon_domain" {
  value = "${aws_instance.host.public_dns}"
}