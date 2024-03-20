#!/bin/bash

instance_id=$(aws autoscaling describe-auto-scaling-instances --profile $profile --region $region | jq '.AutoScalingInstances[] | select(.AutoScalingGroupName=="'$autoscaling_group_name'").InstanceId'| sed 's/"//g' )
bastion_public_dns=$(aws ec2 describe-instances --profile $profile --region $region --instance-ids $instance_id | jq -r '.Reservations[].Instances[].PublicDnsName')

mkdir -p "tmp/keys/"
keyfile="tmp/keys/$deployment_name-keypair-$region.pem"
echo "$ssh_private_key" | sed 's/<<EOT/---/; s/EOT//' > "$keyfile"
chmod 600 "$keyfile"

#ssh -oStrictHostKeyChecking=no -i "$keyfile" -q ec2-user@"$bastion_public_dns" exit
scp -oStrictHostKeyChecking=no -i "$keyfile" "$script_location"boomi-userdata-scripts/deploy_boomi.sh  ec2-user@"$bastion_public_dns":/home/ec2-user/deploy_boomi.sh
ssh -oStrictHostKeyChecking=no -i"$keyfile" ec2-user@"$bastion_public_dns" "helm uninstall -n eks-boomi-molecule boomi-k8s-molecule "