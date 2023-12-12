#!/bin/bash
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_version}/bin/linux/amd64/kubectl
sudo chmod a+x kubectl
sudo mv kubectl /usr/local/bin
su ec2-user -c 'aws eks update-kubeconfig --region ${region} --name ${cluster_name}'