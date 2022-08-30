variable "schedule_expression" {
    type    = string
    default = "rate(40 minutes)"//
}
variable "mail_sns" {
    type    = string
    default = "cohentomer94@gmail.com"//
}