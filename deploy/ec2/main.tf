# Define the AWS provider
provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket        = "my-example-s3-bucket"  # Replace with your desired bucket name
  acl           = "private"              # Access control (default: private)

  tags = {
    Name        = "ExampleS3Bucket"
    Environment = "Dev"
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "example_bucket_versioning" {
  bucket = aws_s3_bucket.example_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example_bucket_encryption" {
  bucket = aws_s3_bucket.example_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Or "aws:kms" for KMS encryption
    }
  }
}

# Optional: Create a public read bucket policy (if required)
# Note: Use with caution; public access is usually discouraged.
resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.example_bucket.arn}/*"
      }
    ]
  })
}
