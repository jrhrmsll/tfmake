locals {
  content = "D module"  
}

resource "local_file" "file" {
  content  = local.content
  filename = "${path.module}/out.txt"
}

resource "random_id" "id" {
  keepers = {
    content = local.content
  }

  byte_length = 8
  
}

output "id" {
  value = random_id.id.id
}
