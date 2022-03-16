# Input Variables
############################
## AWS environments
variable "company" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "MZ"
}
variable "environment" {
  description = "What current stage is your resource "
  type        = string
  default     = "TRAINING"
}
variable "region" {
  description = "The region to deploy the cluster in, e.g: ap-northeast-2"
  type    = string
  default = "ap-northeast-2"
}
variable "ec2_key_name" {
  default     = "handsonkey" # EC2 pem 파일 이름을 정의
}

variable "cluster_name" {
  default     = "kubernetes-practice" # 
}
############################
## EKS version
variable "kube_version" {
  default     = "1.21" # 2021.06.01일 기준 최신버전의 쿠버네티스 
}

############################
## VPC base parameters
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "192.168.0.0/16"
}
variable "enable_nat" {
  description = "If you don't have to create nat, you are defined false"
  type    = bool
  default = true
}
variable "single_nat" {
  description = "All public subnet NAT G/W install or not"
  type    = bool
  default = true
}

############################
## VPC base parameters2 
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}
variable "assign_generated_ipv6_cidr_block" {
  description = "Define whether to use ipv6"
  type        = string
  default     = "false"
}
