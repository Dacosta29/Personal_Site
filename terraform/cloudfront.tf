locals {
  s3_origin_id   = aws_s3_bucket.dacosta.id
  s3_domain_name = "${local.s3_origin_id}.s3-website.${var.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "dacosta" {
  
  enabled = true
  
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = local.s3_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    
    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"
  
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.dacosta.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.dacosta.domain_name
}