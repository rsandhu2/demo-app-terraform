Below are the steps to setup the infrastructure for the demo app.

# Getting Started

## Pre-reqs
1. Download Terraform: https://www.terraform.io/downloads.html
2. Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
3. Setup AWS profile with secret/access keys
```bash
aws configure --profile <profile name>
export AWS_DEFAULT_PROFILE=<profile name>
export AWS_PROFILE=<profile name>
```
4. Lambda zipped code in the same dir as terraform


## Required infrastructure setup before executing terraform.
1. VPC & subnets
2. RDS database setup
3. Security group with connectivity between Lambda and RDS
```base
Variables listed in the variables.tf file are from us-east-2 region.
```


## Build infrastructure

* Change directory to terraform dir
* Update
* `terraform init` -- initializes the directory, downloads needed providers
* `terraform plan` -- outputs the information regarding resources to be built/modified
* `terraform apply` -- creates the resources. 
```bash
terrform will output the S3 bucket name where static web content will be uploaded in the next step
```


## Post terraform steps
1. Copy the static React App code to S3 bucket created by terraform


## Destroy infrastructure
* `terraform destroy` -- destroy all resources once done testing
