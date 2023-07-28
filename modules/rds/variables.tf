variable "cred" {
  type = object({
    username : string,
    password : string
  })
  default = null
}