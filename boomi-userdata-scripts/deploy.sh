#!/bin/bash

instance_id=$(aws autoscaling describe-auto-scaling-instances --profile $profile --region $region | jq '.AutoScalingInstances[] | select(.AutoScalingGroupName=="'$autoscaling_group_name'").InstanceId'| sed 's/"//g' )
bastion_public_dns=$(aws ec2 describe-instances --profile $profile --region $region --instance-ids $instance_id | jq -r '.Reservations[].Instances[].PublicDnsName')

rm -rf "tmp/keys/"
mkdir -p "tmp/keys/"
keyfile="tmp/keys/$deployment_name-keypair-$region.pem"
echo "$ssh_private_key" | sed 's/<<EOT/---/; s/EOT//' > "$keyfile"
chmod 600 "$keyfile"

ssh -q -o StrictHostKeyChecking=no -i "$keyfile" ec2-user@"$bastion_public_dns" exit
while [ $? != 0 ]
do
  echo "Bastion Host is not available for ssh, waiting for ssh to be available for boomi deployment"
  sleep 60
  ssh -q -o StrictHostKeyChecking=no -i "$keyfile" ec2-user@"$bastion_public_dns" exit
done


ssh -oStrictHostKeyChecking=no -i "$keyfile" ec2-user@"$bastion_public_dns" "aws eks update-kubeconfig --region $region --name $deployment_name"
scp -oStrictHostKeyChecking=no -i "$keyfile" "$script_location"boomi-userdata-scripts/deploy_boomi.sh  ec2-user@"$bastion_public_dns":/home/ec2-user/deploy_boomi.sh
ssh -oStrictHostKeyChecking=no -i "$keyfile" ec2-user@"$bastion_public_dns" "chmod u+x /home/ec2-user/deploy_boomi.sh && /home/ec2-user/deploy_boomi.sh $deployment_name $region"