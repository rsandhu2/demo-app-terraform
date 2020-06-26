variable "region" {
  type    = string
  default = "us-east-2"
  description = "region to deploy the app to"
}

variable lambda_zip_file {
  type = string
  default  = "ffi-get-inventories"
  description = "lambda zipped archive to reference"
}

variable api_route {
  type = string
  default = "/ffigetinventories"
  description = "api route"
}

variable "vpc_id" {
  type = string
  default = "vpc-220ec049"
  description = "vpc id"
}

variable "vpc_cidr" {
  type = string
  default = "172.31.0.0/16"
  description = "vpc cidr"
}

variable "subnets" {
  type = list
  default = ["subnet-53c85f1f", "subnet-fc06f097", "subnet-feae8284"]
  description = "subnets associated with lambda function, RDS needs to be running in the same subnet for simplicity for now"
}

variable security_group_id {
  type = string
  default = "sg-0a33b12f63647869f"
  description = "security group to be associated with the lambda"
}
