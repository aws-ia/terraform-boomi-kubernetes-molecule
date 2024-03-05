#!/bin/bash

helm package boomi-k8s-molecule-manifest/boomi-k8s-molecule

terraform init
terraform apply --auto-approve -var-file=variables.tfvars

profile=$(terraform output profile  | sed 's/"//g')
region=$(terraform output region| sed 's/"//g')
autoscaling_group_name=$(terraform output autoscaling_group_name | sed 's/"//g')
instance_id=$(aws autoscaling describe-auto-scaling-instances --profile $profile --region $region | jq '.AutoScalingInstances[] | select(.AutoScalingGroupName=="'$autoscaling_group_name'").InstanceId'| sed 's/"//g' )
bastion_public_dns=$(aws ec2 describe-instances --profile $profile --region $region --instance-ids $instance_id | jq -r '.Reservations[].Instances[].PublicDnsName')
deployment_name=$(terraform output deployment_name  | sed 's/"//g')

mkdir -p "tmp/keys/"
keyfile="tmp/keys/$deployment_name-keypair-$region.pem"
ssh_key=$(terraform output ssh_private_key || kill -SIGINT $$)
echo "$ssh_key" | sed 's/<<EOT/---/; s/EOT//' > "$keyfile"
chmod 600 "$keyfile"

scp -oStrictHostKeyChecking=no -i "$keyfile" boomi-userdata-scripts/deploy_boomi.sh  ec2-user@"$bastion_public_dns":/home/ec2-user/deploy_boomi.sh
ssh -oStrictHostKeyChecking=no -i"$keyfile" ec2-user@"$bastion_public_dns" "chmod u+x /home/ec2-user/deploy_boomi.sh && /home/ec2-user/deploy_boomi.sh $deployment_name $region"