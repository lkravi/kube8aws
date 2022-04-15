/*
resource "aws_ssm_document" "cloud_init_wait" {
  name = "cloud-init-wait"
  document_type = "Command"
  document_format = "YAML"
  content = <<-DOC
    schemaVersion: '2.2'
    description: Wait for cloud init to finish
    mainSteps:
    - action: aws:runShellScript
      name: StopOnLinux
      precondition:
        StringEquals:
        - platformType
        - Linux
      inputs:
        runCommand:
        - cloud-init status --wait
    DOC
}*/

#Bastion
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.allow_ssh.id]
  key_name          =   aws_key_pair.k8_ssh.key_name
  ##https://github.com/hashicorp/terraform/issues/30134
  user_data = <<-EOF
                #!bin/bash
                echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
                systemctl reload sshd
                echo "${tls_private_key.ssh.private_key_pem}" >> /home/ec2-user/.ssh/id_rsa
                chown ec2-user /home/ec2-user/.ssh/id_rsa
                chgrp ec2-user /home/ec2-user/.ssh/id_rsa
                chmod 600   /home/ec2-user/.ssh/id_rsa
                echo "starting ansible install" > start.log
                mkdir /home/ec2-user/tmp
                export TMPDIR=/home/ec2-user/tmp/
                yum update -y > /home/ec2-user/yupdate.log
                yum install -y python3-pip > /home/ec2-user/pip.log
                pip3 install ansible > /home/ec2-user/ansi.log
                echo "user data done" > /home/ec2-user/user-data.log
                EOF

  tags = {
    Name = "Bastion"
  }

/*
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOF
    set -Ee -o pipefail
    export AWS_DEFAULT_REGION="${var.AWS_REGION}"

    command_id=$(aws ssm send-command --document-name ${aws_ssm_document.cloud_init_wait.arn} --instance-ids ${self.id} --output text --query "Command.CommandId")
    if ! aws ssm wait command-executed --command-id $command_id --instance-id ${self.id}; then
      echo "Failed to start services on instance ${self.id}!";
      echo "stdout:";
      aws ssm get-command-invocation --command-id $command_id --instance-id ${self.id} --query StandardOutputContent;
      echo "stderr:";
      aws ssm get-command-invocation --command-id $command_id --instance-id ${self.id} --query StandardErrorContent;
      exit 1;
    fi;
    echo "Services started successfully on the new instance with id ${self.id}!"

    EOF
  }
*/
}


#Master
resource "aws_instance" "masters" {
  count         = var.master_node_count
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id = module.vpc.private_subnets[0] #TODO need to pick psub round-robin
  key_name          =   aws_key_pair.k8_ssh.key_name

  tags = {
    Name = format("Master-%02d", count.index + 1)
  }
}

#Worker
resource "aws_instance" "workers" {
  count         = var.worker_node_count
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id = module.vpc.private_subnets[0] #TODO need to pick psub round-robin
  key_name          =   aws_key_pair.k8_ssh.key_name

  tags = {
    Name = format("Worker-%02d", count.index + 1)
  }
}