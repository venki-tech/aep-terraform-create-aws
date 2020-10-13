#!/bin/bash

echo "-------------------------------------"
rm -rf ${WORKSPACE}/temp_repo_ws
cd ${WORKSPACE}/aep-terraform-create-aws/
git remote set-url origin git@github.com:venki-tech/aep-terraform-create-aws.git
git add terraform.tfstate*
git commit -m "Added terraform state files to repo" || true
git push origin HEAD:master

. ./supply_hosts.txt
echo "Creating inventory file for current run for deploy"
inv_file_deploy="${keyname}_deploy_inventory.txt"
cp inventory.txt ${inv_file_deploy}
echo "Creating hosts file to be copied to the newly provisioned servers"
hosts_file="${keyname}_hosts"
perl -0777 -nle 'print "$2\t$1\n" while m/(.*) ansible_host=(.*)ansible_connection/g' ${inv_file_deploy} > ${hosts_file}
perl -i -pe 's/^(.*db[0-9]*)/$1   db/g' ${hosts_file}

mkdir -p ${WORKSPACE}/temp_repo_ws
echo "Copying files into temp_repo_ws"
cp terraform.tfstate* inventory.txt supply_hosts.txt ${inv_file_deploy} ${hosts_file} ${WORKSPACE}/temp_repo_ws/

rm -rf ${WORKSPACE}/aep-terraform-create-aws

echo "-------------------------------------"
cd ${WORKSPACE}
git clone git@github.com:venki-tech/aep-ansible-provision.git
cd ${WORKSPACE}/aep-ansible-provision

echo "Copy file ${WORKSPACE}/temp_repo_ws/${inv_file_deploy} to current location"
cp ${WORKSPACE}/temp_repo_ws/${inv_file_deploy} .

echo "Update within temp location contents of hosts.template from ${WORKSPACE}/temp_repo_ws/${hosts_file}"
cp ${WORKSPACE}/aep-ansible-provision/hosts.template ${WORKSPACE}/temp_repo_ws/
cat ${WORKSPACE}/temp_repo_ws/${hosts_file} >> ${WORKSPACE}/temp_repo_ws/hosts.template

echo "Showing conents of ${WORKSPACE}/temp_repo_ws/hosts.template:"
cat ${WORKSPACE}/temp_repo_ws/hosts.template
echo
echo

if [[ -f runninginventory.txt ]];then
  echo "Check if the servers already exists, if yes do not add it to runninginventory.txt"
  cp ${WORKSPACE}/temp_repo_ws/supply_hosts.txt .
  exists=$(grep hosts_exists supply_hosts.txt|cut -f2 -d'=')
  if [[ $exists == "no" ]];then
      echo "runninginventory.txt file exists and the hosts are newly provisioned. Will add the new hosts into it."
      cp ${WORKSPACE}/temp_repo_ws/inventory.txt .

      perl -0777 -nle 'print $1 if m/(\[all\](.|\n|\r)*)\[aws_instances/g' runninginventory.txt >> newrunninginventory.txt
      perl -0777 -nle 'print $1 if m/all\]((.|\n|\r)*)\[aws_instances/g' inventory.txt >> newrunninginventory.txt
      perl -0777 -nle 'print $1 if m/(\[aws_instances\](.|\n|\r)*)/g' runninginventory.txt  >> newrunninginventory.txt
      perl -0777 -nle 'print $1 if m/aws_instances\]((.|\n|\r)*)/g' inventory.txt >> newrunninginventory.txt

      mv -f newrunninginventory.txt runninginventory.txt
      rm -f inventory.txt
  fi
else
  echo "Running inventory file doesnt exist. Will just rename inventory file as runninginventory file"
  cp ${WORKSPACE}/temp_repo_ws/inventory.txt .
  mv inventory.txt runninginventory.txt
fi

git add runninginventory.txt ${inv_file_deploy}
git commit -m "Added inventory files to repo" || true
git push origin HEAD:master
rm -rf ${WORKSPACE}/aep-ansible-provision
