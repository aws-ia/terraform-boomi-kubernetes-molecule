#!/bin/bash

# Install Git
#sudo yum update -y
#sudo yum install git -y
sudo yum install jq -y

# Installing aws cli v2
sudo yum remove awscli -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
export PATH=$HOME/.local/bin:$PATH

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

aws eks update-kubeconfig --region ${region} --name ${cluster_name}