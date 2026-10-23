# Fixed demo infrastructure: private bucket, restricted SSH, least-privilege IAM,
# no NAT gateway, small encrypted instance. Still only planned, never applied.

resource "aws_s3_bucket" "logs" {
  bucket = "ammar-demo-private-logs-12345"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "ssh_restricted" {
  name        = "ssh-restricted"
  description = "Allows SSH from one trusted IP only"

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"]
  }
}

resource "aws_iam_policy" "read_logs" {
  name = "read-logs-only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.logs.arn}/*"
    }]
  })
}

resource "aws_instance" "small" {
  ami           = "ami-00000000000000000"
  instance_type = "t3.micro"

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }
}
