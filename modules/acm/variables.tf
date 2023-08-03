variable "hostedZone" {
  type = string
  default = null
}

variable "applications" {
  type = list(object({
    name = string
    dnsPrefix = string
  }))
}

variable "zone_id" {
  type = string
  default = "Z02992983P6JBHBJ5UT37"
}