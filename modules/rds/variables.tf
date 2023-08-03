variable "cred" {
  type = object({
    username : string,
    password : string
  })
  default = null
}


variable "environment" {
  type = string
  default = null
}


variable "vpc_id" {
  type = string
  default = "vpc-4cc9de24"
}