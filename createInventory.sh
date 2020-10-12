#!/bin/bash

echo "-------------------------------------"
rm -rf ${WORKSPACE}/temp_repo_ws
cd ${WORKSPACE}/aep-terraform-create-aws/
git remote set-url origin git@github.com:venki-tech/aep-terraform-create-aws.git
git add terraform.tfstate* inventory.txt
git commit -m "Added terraform state files to repo" || true
git push origin HEAD:master
mkdir -p ${WORKSPACE}/temp_repo_ws
cp terraform.tfstate* inventory.txt ${WORKSPACE}/temp_repo_ws
rm -rf ${WORKSPACE}/aep-terraform-create-aws

echo "-------------------------------------"
cd ${WORKSPACE}
git clone git@github.com:venki-tech/aws-terraform.git
cd ${WORKSPACE}/aws-terraform
git pull
cp ${WORKSPACE}/temp_repo_ws/* .
git add terraform.tfstate* inventory.txt
git commit -m "Added terraform state files to repo" || true
git push origin HEAD:master
rm -rf ${WORKSPACE}/aws-terraform

echo "-------------------------------------"
cd ${WORKSPACE}
git clone git@github.com:venki-tech/aep-ansible-provision.git
cd ${WORKSPACE}/aep-ansible-provision
git pull
if [[ -f runninginventory.txt ]];then
  echo "Running inventory file exists. Will add the new hosts into it.
  cp ${WORKSPACE}/temp_repo_ws/inventory.txt .

  perl -0777 -nle "print $1 if m/(\[all\](.|\n|\r)*)\[aws_instances/g" runninginventory.txt >> newrunninginventory.txt
  perl -0777 -nle "print $1 if m/all\]((.|\n|\r)*)\[aws_instances/g" inventory.txt >> newrunninginventory.txt
  perl -0777 -nle "print $1 if m/(\[aws_instances\](.|\n|\r)*)/g" runninginventory.txt  >> newrunninginventory.txt
  perl -0777 -nle "print $1 if m/aws_instances\]((.|\n|\r)*)/g" inventory.txt >> newrunninginventory.txt

  mv -f newrunninginventory.txt runninginventory.txt
  rm -f inventory.txt
else
  echo "Running inventory file doesnt exist. Will just rename inventory file as runninginventory file"
  cp ${WORKSPACE}/temp_repo_ws/inventory.txt .
  mv inventory.txt runninginventory.txt
fi
git add *inventory*
git commit -m "Added inventory files to repo" || true
git push origin HEAD:master
rm -rf ${WORKSPACE}/aep-ansible-provision
