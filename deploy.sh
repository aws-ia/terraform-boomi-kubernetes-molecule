#!/bin/bash

helm package boomi-k8s-molecule-manifest/boomi-k8s-molecule

terraform init
terraform apply --auto-approve -var-file=variables.tfvars

profile=$(terraform output profile  | sed 's/"//g')
region=$(terraform output region| sed 's/"//g')
autoscaling_group_name=$(terraform output autoscaling_group_name | sed 's/"//g')
instance_id=$(aws autoscaling describe-auto-scaling-instances --profile $profile --region $region | jq '.AutoScalingInstances[] | select(.AutoScalingGroupName=="'$autoscaling_group_name'").InstanceId'| sed 's/"//g' )
bastion_public_dns=$(aws ec2 describe-instances --profile $profile --region $region --instance-ids $instance_id | jq -r '.Reservations[].Instances[].PublicDnsName')
efs_id=$(terraform output efs_id  | sed 's/"//g')
install_token=$(terraform output boomi_install_token  | sed 's/"//g')
deployment_name=$(terraform output deployment_name  | sed 's/"//g')
boomi_account_id=$(terraform output boomi_account_id  | sed 's/"//g')
boomi_username=$(terraform output boomi_username  | sed 's/"//g')

mkdir -p "tmp/keys/"
keyfile="tmp/keys/$deployment_name-keypair-$region.pem"
ssh_key=$(terraform output ssh_private_key || kill -SIGINT $$)
echo "$ssh_key" | sed 's/<<EOT/---/; s/EOT//' > "$keyfile"
chmod 600 "$keyfile"

helm_install_command="helm install -n eks-boomi-molecule --create-namespace --set MoleculeClusterName="k8s-boomi-molecule" --set boomi_username=$boomi_username --set boomi_account_id=$boomi_account_id --set boomi_mfa_install_token=$install_token --set efs_id=$efs_id --set base_path=$deployment_name boomi-k8s-molecule boomi-k8s-molecule/"
ssh -i "$keyfile" ec2-user@"$bastion_public_dns" "aws s3 cp s3://$deployment_name-artifact-bucket/$deployment_name-boomi-k8s-molecule - | tar -xz"
ssh -i "$keyfile" ec2-user@"$bastion_public_dns" "$helm_install_command"