#!/bin/bash
deployment_name=$1
region=$2

account_id=$(aws secretsmanager get-secret-value --region $region --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .boomi_account_id)
boomi_username=$(aws secretsmanager get-secret-value  --region $region --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .boomi_username)
efs_driver_role_arn=$(aws secretsmanager get-secret-value --region $region  --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .efs_driver_role_arn)
efs_id=$(aws secretsmanager get-secret-value --region $region --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .efs_id)
install_token=$(aws secretsmanager get-secret-value --region $region --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .install_token)
s3_bucket_name=$(aws secretsmanager get-secret-value --region $region --secret-id $deployment_name-eks-blueprint| jq --raw-output '.SecretString' | jq -r .s3_bucket_name)

aws eks update-kubeconfig --region $region --name $deployment_name
aws eks create-addon --cluster-name $deployment_name --region $region --addon-name aws-efs-csi-driver --service-account-role-arn $efs_driver_role_arn

aws s3 cp s3://$s3_bucket_name/$deployment_name-boomi-k8s-molecule .
unzip $deployment_name-boomi-k8s-molecule -d boomi-k8s-molecule
helm upgrade --install -n eks-boomi-molecule --create-namespace --set MoleculeClusterName="k8s-boomi-molecule" --set boomi_username=$boomi_username --set boomi_account_id=$boomi_account_id --set boomi_mfa_install_token=$install_token --set efs_id=$efs_id --set base_path=$deployment_name boomi-k8s-molecule boomi-k8s-molecule/
rm -rf *