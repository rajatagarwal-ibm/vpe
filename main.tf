##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3.0"
  # Pin to the lowest provider version of the range defined in the main module's version.tf to ensure lowest version still works
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.52.0"
    }
    # The time provider is not actually required by the module itself, just this example, so OK to use ">=" here instead of locking into a version
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  description = "The region where VPC and services are deployed"
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
  default     = "test-vpe"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names. It is also used to create a VPC when the vpc_id input is set to null."
  type        = string
  default     = "vpc-instance"
}

variable "vpc_id" {
  description = "ID of the VPC where the Endpoint Gateways will be created. Creates a VPC if set to null."
  type        = string
  default     = null
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where gateways and reserved IPs will be provisioned. This value is intended to use the `subnet_zone_list` output from the ICSE VPC Subnet Module (https://github.com/Cloud-Schematics/vpc-subnet-module) or from templates using that module for subnet creation."
  type = list(
    object({
      name = string
      id   = string
      zone = optional(string)
      cidr = optional(string)
    })
  )
  default = []
}

variable "security_group_ids" {
  description = "List of security group ids to attach to each endpoint gateway."
  type        = list(string)
  default     = null
}


variable "cloud_services" {
  description = "List of cloud services to create an endpoint gateway."
  type        = list(string)
  default     = ["kms",
  "hs-crypto",
"cloud-object-storage",
"account-management",
"billing",
"codeengine",
"directlink",
"dns-svcs",
"enterprise",
"globalcatalog",
"global-search-tagging",
"hyperp-dbaas-mongodb",
"hyperp-dbaas-postgresql",
"iam-svcs",
"resource-controller",
"transit",
"user-management",
"is"]
}

variable "cloud_service_by_crn" {
  description = "List of cloud service CRNs. Each CRN will have a unique endpoint gateways created. For a list of supported services, see the docs [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services)."
  type = list(
    object({
      name = string # service name
      crn  = string # service crn
    })
  )
  default = []
}

variable "service_endpoints" {
  description = "Service endpoints to use to create endpoint gateways. Can be `public`, or `private`."
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public` or `private`."
    condition     = contains(["public", "private"], var.service_endpoints)
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

##############################################################################

##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC for this example using defaults from terraform-ibm-landing-zone-vpc
# ( 3 subnets across the 3 AZs in the region )
##############################################################################

module "vpc" {
  count             = var.vpc_id != null ? 0 : 1
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v7.0.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
  tags              = var.resource_tags
}

##############################################################################
# Demonstrate how to create a custom security group that is applied to the VPEs
# This examples allow all workload associated with the default VPC security group
# to interact with the VPEs
##############################################################################

data "ibm_is_vpc" "vpc" {
  # Explicit depends as the vpc_name is known prior to VPC creation
  depends_on = [
    module.vpc
  ]
  name = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_name
}

data "ibm_is_security_group" "default_sg" {
  name = data.ibm_is_vpc.vpc.default_security_group_name
}

module "vpe_security_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-security-group.git?ref=v1.0.0"
  security_group_name          = "${var.prefix}-vpe-sg"
  add_ibm_cloud_internal_rules = false # No need for the internal ibm cloud rules for SG associated with VPEs

  security_group_rules = [{
    name      = "allow-all-default-sg-inbound"
    direction = "inbound"
    remote    = data.ibm_is_security_group.default_sg.id
  }]

  resource_group = module.resource_group.resource_group_id
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.vpe_security_group]

  destroy_duration = "30s"
}

##############################################################################
# Create VPEs in the VPC
##############################################################################
module "vpes" {
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-vpe-module.git?ref=add-services-support"
  region               = var.region
  prefix               = var.prefix
  vpc_name             = var.vpc_name
  vpc_id               = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  subnet_zone_list     = var.vpc_id != null ? var.subnet_zone_list : module.vpc[0].subnet_zone_list
  resource_group_id    = module.resource_group.resource_group_id
  security_group_ids   = var.security_group_ids != null ? var.security_group_ids : [module.vpe_security_group.security_group_id]
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  #  Wait 30secs after security group is destroyed before destroying VPE to workaround timing issue which can produce “Target not found” error on destroy
  depends_on = [time_sleep.wait_30_seconds]
}
