variable "name" {
  description = "the name of infrastructure project"
}
variable "destroy" {
  default = false
}
variable "tags" {
  default     = {
      Purpose = "terraform state storage"
  }
}

# access_key, secret_key, region are provided by env varaibles
provider "aws" {}

resource "aws_s3_bucket" "bucket" {
  tags   = "${var.tags}"
  bucket = "${var.name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
 }
  force_destroy = "${var.destroy}"
}

resource "aws_dynamodb_table" "table" {
  tags         = "${var.tags}"
  name         = "${var.name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
}

############## outputs #################
output "bucket" {
  value = "${aws_s3_bucket.bucket.bucket}"
}
output "table" {
  value = "${aws_dynamodb_table.table.name}"
}