resource "random_string" "random" {
  length  = 8
  lower   = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "dacosta" {
  bucket = "dacosta-${random_string.random.result}"
} 

resource "aws_s3_bucket_ownership_controls" "dacosta" {
  bucket = aws_s3_bucket.dacosta.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "dacosta" {
  bucket = aws_s3_bucket.dacosta.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "dacosta" {
  depends_on = [
    aws_s3_bucket_public_access_block.dacosta,
    aws_s3_bucket_ownership_controls.dacosta,
  ]

  bucket = aws_s3_bucket.dacosta.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.dacosta.id

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Id": "Policy1234567890123",
    "Statement": [
        {
            "Sid": "Stmt1234567890123",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.dacosta.id}/*"
        }
    ]
}
EOT
}

resource "aws_s3_bucket_website_configuration" "dacosta" {
  bucket = aws_s3_bucket.dacosta.id

  index_document {
    suffix = "index.html"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.dacosta.id
}

output "s3_static_website_url" {
  value = aws_s3_bucket_website_configuration.dacosta
}

output "s3_domain_name" {
  value = aws_s3_bucket.dacosta.bucket_domain_name
}
