
resource "aws_s3_bucket" "website-meital" {
    bucket = "website-meital"
    acl = "public-read" 
  
}



resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website-meital.id
  block_public_acls   = false
  block_public_policy = false
}


#Upload an object (static_website) to s3 bucket
resource "aws_s3_bucket_object" "object" {
  depends_on = [aws_s3_bucket.website-meital]
  bucket = aws_s3_bucket.website-meital.id
  acl = "public-read"
  for_each = fileset ("/Users/meitalost/Documents/Terraform projects/project1/s3/static_website","*")
  key = each.value
  source = "/Users/meitalost/Documents/Terraform projects/project1/s3/static_website/${each.value}"
  etag = filemd5 ("/Users/meitalost/Documents/Terraform projects/project1/s3/static_website/${each.value}")
}