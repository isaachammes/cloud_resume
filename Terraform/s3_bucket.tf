
resource "aws_s3_bucket" "resume_S3_bucket" {
  bucket = var.domain

  website {
    index_document = var.index
    error_document = var.index
  }
}

locals {
  src_dir      = "../S3/"
  content_type_map = {
    html        = "text/html",
    css         = "text/css",
    png         = "image/png",
  }
}

resource "aws_s3_bucket_object" "site_files" {
  for_each = fileset(local.src_dir, "*")

  bucket        = var.domain
  key           = each.value
  source        = "${local.src_dir}${each.value}"

  content_type  = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension)

  depends_on = [aws_s3_bucket.resume_S3_bucket]
}

resource "aws_s3_bucket_object" "add_js_to_s3" {

  bucket = var.domain
  key    = "counter.js"

  content = <<EOT
  const apiUrl = "${aws_api_gateway_deployment.apideploy.invoke_url}"
  const countElement = document.getElementById('count');

  updateVisitCount();

  function updateVisitCount() {
      fetch(apiUrl)
          .then(res => res.json())
          .then(res => {
          countElement.innerHTML = res;
      });
  }
EOT

  content_type = "application/javascript"
  depends_on = [aws_s3_bucket.resume_S3_bucket, aws_api_gateway_deployment.apideploy]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_S3_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.resume_S3_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
