resource "aws_instance" "myec2" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2.id]
  key_name = "aws-key"
  subnet_id = aws_subnet.public.id
}