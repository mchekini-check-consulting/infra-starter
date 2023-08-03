variable "ec2_keyName" {
  type    = string
  default = null
}

variable "ec2-instances" {
  type = list(object({
    subnet : string
    type: string
    volumeSize: number
  }))
  default = null
}

variable "applications" {
  type = list(object({
    name = string
    dnsPrefix = string
    port = number
  }))
}

variable "hostedZone" {
  type = string
  default = null
}

variable "environment" {
  type = string
  default = null
}

variable "instance-profile-name" {
  type = string
  default = null
}

variable "vpc_id" {
  type = string
  default = "vpc-4cc9de24"
}

variable "certificate_arn" {
  type = string
  default = null
}