# Kubernetes cluster with Kubeadm on AWS using Terraform & Ansible.

Terraform, Ansible, Docker, cri-dockerd, kubeadm, Kubernetes

This repo contain the all required automation code for setting up Kubernetes cluster using kubeadm in AWS cloud environment.

## Infrastructure Provisioning
We have used Terraform for all the Infrastructure Provisioning automation.

## Kubernetes Cluster Setup 
We have used Ansible for all Server & Cluster configurations.





### Issues:
I have experienced following issues so far when I working with different flavors of Linux.

Amazon-linux2
https://github.com/ansible/ansible/issues/62722

Centos
https://github.com/hashicorp/terraform/issues/30134
