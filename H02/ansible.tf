resource "local_file" "inventory" {
  content = templatefile("inventory.template",
    {
      public_ip = aws_instance.myec2.public_ip
    }
  )
  filename = "inventory"
}

resource "time_sleep" "wait" {
  depends_on = [aws_instance.myec2]
  create_duration = "150s"
}

resource "null_resource" "run_ansible"{
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory playbook.yml"
  }
  depends_on = [time_sleep.wait]
}