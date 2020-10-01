### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl",
  {
    aws_u1 = aws_instance.u1.public_ip,
    aws_u2 = aws_instance.u2.public_ip,
    aws_rhel1 = aws_instance.rhel1.public_ip,
  }
 )
 filename = "inventory.txt"
}
