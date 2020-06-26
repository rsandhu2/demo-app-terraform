Below are the steps to setup the infrastructure for the demo app.

# Getting Started

## Pre-reqs
* Download Terraform: https://www.terraform.io/downloads.html
* Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
* Setup AWS profile with secret/access keys
```bash
aws configure --profile <profile name>
export AWS_DEFAULT_PROFILE=<profile name>
export AWS_PROFILE=<profile name>
```


# Run terraform

* Change directory to terraform dir
* `terraform init` -- initializes the directory, downloads needed providers
* `terraform plan` -- outputs the information regarding resources to be built/modified
* `terraform apply` -- creates the resources
* `terraform destroy` -- destroy all resources
