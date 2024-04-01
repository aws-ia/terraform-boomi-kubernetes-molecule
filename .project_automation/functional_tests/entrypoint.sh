#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** MAKEFILE *************
echo "Build the lambda function packages"
make clean build

#********** Get TF-Vars ******************
#boomi_username = ""
#boomi_account_id = ""
#boomi_install_token = ""
#aws_profile = "default"

aws ssm get-parameter \
    --name "/terraform-boomi-kubernetes-molecule" \
    --with-decryption \
    --query "Parameter.Value" \
    --output "text" \
    --region "us-east-1">>tf.auto.tfvars

########## Copy tfvars to examples #########

cp tf.auto.tfvars examples/boomi-molecule-with-new-vpc


#********** Checkov Analysis *************
echo "Running Checkov Analysis"
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 
checkov --config-file ${PROJECT_PATH}/.config/.checkov.yml

#********** Terratest execution **********
echo "Running Terratest"
cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 45m

echo "End of Functional Tests"