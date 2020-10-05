### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl",
  {
    appserver_ip = aws_instance.appserver.public_ip,
    dbserver_ip = aws_instance.dbserver.public_ip,
    webserver_ip = aws_instance.webserver.public_ip,
  }
 )
 filename = "inventory.txt"
}
