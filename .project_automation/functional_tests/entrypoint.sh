#!/bin/bash

## WARNING: DO NOT modify the content of entrypoint.sh
# Use ./config/functional_tests/pre-entrypoint-helpers.sh or ./config/functional_tests/post-entrypoint-helpers.sh 
# to load any customizations or additional configurations

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

#********** helper functions *************
pre_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/functional_tests/pre-entrypoint-helpers.sh ]; then
        echo "Pre-entrypoint helper found"
        source ${PROJECT_PATH}/.config/functional_tests/pre-entrypoint-helpers.sh
        echo "Pre-entrypoint helper loaded"
    else
        echo "Pre-entrypoint helper not found - skipped"
    fi
}
post_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/functional_tests/post-entrypoint-helpers.sh ]; then
        echo "Post-entrypoint helper found"
        source ${PROJECT_PATH}/.config/functional_tests/post-entrypoint-helpers.sh        
        echo "Post-entrypoint helper loaded"
    else
        echo "Post-entrypoint helper not found - skipped"
    fi
}

#********** Pre-entrypoint helper *************
pre_entrypoint

<<<<<<< before updating
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
#checkov --config-file ${PROJECT_PATH}/.config/.checkov.yml

#********** Terratest execution **********
echo "Running Terratest"
cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 90m
=======
#********** Functional Test *************
/bin/bash ${PROJECT_PATH}/.project_automation/functional_tests/functional_tests.sh
if [ $? -eq 0 ]
then
    echo "Functional test completed"
    EXIT_CODE=0
else
    echo "Functional test failed"
    EXIT_CODE=1
fi

#********** Post-entrypoint helper *************
post_entrypoint
>>>>>>> after updating

#********** Exit Code *************
exit $EXIT_CODE