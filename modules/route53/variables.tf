variable "hostedZone" {
  type = string
  default = null
}

variable "alb-dns-name" {
  type = string
  default = null
}

variable "alb-zone-id" {
  type = string
  default = null
}

variable "applications" {
  type = list(object({
    name = string
    dnsPrefix = string
  }))
}


variable "ec2-instances" {
  type = list(object({
    subnet : string
    type: string
    volumeSize: number
  }))
  default = null
}

variable "ec2-ips" {
  type = list(string)
  default = null
}

variable "environment" {
  type = string
}

variable "zone_id" {
  type = string
  default = "Z02992983P6JBHBJ5UT37"
}