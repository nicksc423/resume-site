# Name of the APIGW instance
variable "resource_name" {
    type = string
}

variable "lambda" {
}

variable "certificate_arn" {
    type = string
}

variable "dns_root_name" {
    type = string
}

variable "r53_zoneID" {
    type = string
}
