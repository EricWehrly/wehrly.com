# https://gist.github.com/danihodovic/a51eb0d9d4b29649c2d094f4251827dd

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "domain" {
  type = string
}

variable "filedir" {
  type = string
  default = "empty"
}

variable certificate_arn {
  type = string
}

variable "configure_www" {
  type = bool
  default = false
}

provider "aws" {
  region = "${var.aws_region}"
}

# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951
resource "aws_s3_bucket" "site" {
  bucket = "${var.domain}"
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site_access" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# TODO: Should / can we try to make this something we can pass in from the top ... ?

# Note: Creating this route53 zone is not enough. The domain's name servers need to point to the NS
# servers of the route53 zone. Otherwise the DNS lookup will fail.
# To verify that the dns lookup succeeds: `dig site @nameserver`
resource "aws_route53_zone" "main" {
  name = "wehrly.com"
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_domain" {
  count = var.configure_www ? 1 : 0
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "www.${var.domain}"
  type = "CNAME"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.domain}"
    domain_name = "${var.domain}.s3.amazonaws.com"
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  # aliases = ["${var.domain}", "www.${var.domain}"]
  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  # add a www site to the allowed list for the cdn, unless it already is a www site
  aliases = var.configure_www ? [var.domain, "www.${var.domain}"] : [var.domain]

  enabled             = true
  default_root_object = "index.html"
  http_version = "http2and3"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn != "" ? var.certificate_arn : null
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = var.certificate_arn != "" ? false : true
  }
}

output "s3_website_endpoint" {
  value = "${aws_s3_bucket.site.website_endpoint}"
}

output "route53_domain" {
  value = "${aws_route53_record.root_domain.fqdn}"
}

output "cdn_domain" {
  value = "${aws_cloudfront_distribution.cdn.domain_name}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.site.id}"
}
