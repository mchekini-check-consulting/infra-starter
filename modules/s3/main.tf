resource "aws_s3_bucket" "staff-manager-bucket" {
  count = length(var.bucket_names)
  bucket = format("%s-%s",var.environment,var.bucket_names[count.index])
}



