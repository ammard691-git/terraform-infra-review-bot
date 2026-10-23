# Deliberately risky demo infrastructure. It is only ever planned, never applied.

resource "aws_s3_bucket" "logs" {
  bucket = "ammar-demo-public-logs-12345"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_security_group" "ssh_open" {
  name        = "ssh-open"
  description = "Allows SSH from anywhere"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "god_mode" {
  name = "god-mode"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "subnet-00000000000000000"
}

resource "aws_instance" "big" {
  ami           = "ami-00000000000000000"
  instance_type = "p4d.24xlarge"
}
