# Kubernetes cluster with Kubeadm on AWS using Terraform & Ansible.

### Tech Stack
Terraform, Ansible, Docker, cri-dockerd, kubeadm, Kubernetes, Ubuntu, AWS {VPC, EC2, NLB}

This repo contain the all required automation code for setting up Kubernetes cluster using kubeadm in AWS cloud environment. I have tested all the scripts successfully on Ubuntu 18.04.

#### Infrastructure Provisioning
Terraform for all the infrastructure provisioning automation.

#### Kubernetes Cluster Setup 
Ansible for all Server & Cluster configurations.

## Architecture Diagram
![alt text](https://raw.githubusercontent.com/lkravi/kube8aws/multi-master/architecture.png)


### Prerequisites
* You need to have your [AWS CLI configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 

## Usage

Clone this repo first then check the vars.tf for the AWS & Kubernetes cluster configurations. I already added default values for each variable. You can override any variable via command line or as a variable file.

> If you are changing AWS region, please make sure to change the ami_id variable as well. You can click [here](https://cloud-images.ubuntu.com/locator/ec2/) to locate ubuntu ami for any AWS region.

Once you review the configuration you just need to apply the terraform code.

    terraform init
    terraform plan 
    terraform apply

Terraform apply will make sure it will provision all required infrastructure and setup kubernetes cluster on top of it.

> To ssh to the Bastion host you can find the "k8_ssh_key.pem" private key in your project folder. This will be dynamically created during infrastructure provisioning and added to the bastion host as well. Same key will be used to configure the ansible host and clients.

## Demo

[![Watch the video](https://img.youtube.com/vi/Oxv7ZA-iOpc/maxresdefault.jpg)](https://www.youtube.com/watch?v=Oxv7ZA-iOpc)

#### Issues:
I have experienced following issues so far when I working with different flavors of Linux.

Amazon-linux2
https://github.com/ansible/ansible/issues/62722

Centos
https://github.com/hashicorp/terraform/issues/30134
