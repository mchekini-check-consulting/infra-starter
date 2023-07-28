variable "hostedZone" {
  type = string
  default = null
}

variable "subdomains" {
  type = list(string)
  default = []
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