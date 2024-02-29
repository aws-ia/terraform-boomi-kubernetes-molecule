#!/bin/bash

# Install Git
sudo yum update -y
sudo yum install git -y

# Install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

# Install kubectl
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_version}/bin/linux/amd64/kubectl
sudo chmod a+x kubectl
sudo mv kubectl /usr/local/bin

cluster_status=$(aws eks describe-cluster --name ${cluster_name} --region ${region} | jq -r '.cluster.status')

while [ "$cluster_status" != "ACTIVE" ]
do
        echo "Cluster Creating..."
        sleep 10
        cluster_status=$(aws eks describe-cluster --name ${cluster_name} --region ${region} | jq -r '.cluster.status')
done

# Updating kubeconfig on bastion host
su ec2-user -c 'aws eks update-kubeconfig --region ${region} --name ${cluster_name}'

# Install EFS CSI Driver addon
su ec2-user -c 'aws eks create-addon --cluster-name ${cluster_name} --region ${region} --addon-name aws-efs-csi-driver'