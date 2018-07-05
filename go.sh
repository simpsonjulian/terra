#!/bin/bash

rm -f world

# unless we have one already, build an AMI
[ -f ami ] || packer build packer.yml | tee ami 

# pass the AMI to Terraform, and deploy the infrastructure
ami_id=$(eval grep ami ami | tail -1 | awk '{print $2}')
terraform apply -auto-approve -var "ami_id=$ami_id" -no-color| tee world
url=$(tail -1 world| awk '{print $3}')

# wait for the instance to register on the load balancer, and DNS records to resolve
while ! curl -f $url 2>/dev/null; do 
  echo -n "."
  sleep 10
done

# highlight the output
echo "${url}"
curl $url | egrep --color 'Hello World|$'
