
resource "local_file" "ansible_inventory" {
    content = templatefile("${path.root}/templates/inventry.tftpl",
        {
            masters-dns = aws_instance.masters.*.private_dns,
            masters-ip  = aws_instance.masters.*.private_ip,
            masters-id  = aws_instance.masters.*.id,
            workers-dns = aws_instance.workers.*.private_dns,
            workers-ip  = aws_instance.workers.*.private_ip,
            workers-id  = aws_instance.workers.*.id
        }    
    )
    filename = "${path.root}/inventory"
}

resource "time_sleep" "wait_300_seconds" {
  depends_on = [aws_instance.bastion]

  create_duration = "300s"

  triggers = {
    "always_run" = timestamp()
  }
}


resource "null_resource" "provisioner" {
  depends_on    = [
    local_file.ansible_inventory,
    time_sleep.wait_300_seconds,
    aws_instance.bastion
    ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
    source  = "${path.root}/inventory"
    destination = "/home/ec2-user/inventory"

    connection {
      type          = "ssh"
      host          = aws_instance.bastion.public_ip
      user          = var.ssh_user
      private_key   = tls_private_key.ssh.private_key_pem
      agent         = false
      insecure      = true
    }
  }
}

resource "null_resource" "copy_ansible_playbooks" {
  depends_on    = [
    null_resource.provisioner,
    time_sleep.wait_300_seconds,
    aws_instance.bastion
    ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
      source = "${path.root}/ansible"
      destination = "/home/ec2-user/ansible/"

      connection {
        type        = "ssh"
        host        = aws_instance.bastion.public_ip
        user        = var.ssh_user
        private_key = tls_private_key.ssh.private_key_pem
        insecure    = true
        agent         = false
      }
    
  }
}


resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.provisioner,
    null_resource.copy_ansible_playbooks,
    aws_instance.masters,
    aws_instance.workers,
    module.vpc,
    aws_instance.bastion,
    time_sleep.wait_300_seconds
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    host        = aws_instance.bastion.public_ip
    user        = var.ssh_user
    private_key = tls_private_key.ssh.private_key_pem
    insecure    = true
    agent         = false
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'starting ansible playbooks...' > /home/ec2-user/ansible-run-started.log",
      "sleep 60 && ansible-playbook -i /home/ec2-user/inventory /home/ec2-user/ansible/play.yml ",
    ] 
  }
}