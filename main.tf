terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
  #backend "remote" {
  #  hostname = "app.terraform.io"
  #  organization = "TheChigozieCO"

  #  workspaces {
  #    name = "terra-house-1"
  #  }
  #}
  # cloud {
  #   organization = "TheChigozieCO"
  #   workspaces {
  #     name = "terra-house-1"
  #   }
  # }
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid= var.teacherseat_user_uuid
  token= var.terratowns_access_token
}
module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  index_html_filepath = var.index_html_filepath
  error_html_filepath = var.error_html_filepath
  content_version = var.content_version
  assets_path = var.assets_path
}

resource "terratowns_home" "home" {
  name = "Escape the chaos, come relax at the beach"
  description = <<DESCRIPTION
We all know how stressful the rat race can be so we all need 
somewhere to go and relax and unwind.
Here are the most relaxing and calming beaches you should visit.
Start by taking in the scenery, relaxation is sure to start from here.
Hope to see you at one of these places in the nearest future.
  DESCRIPTION
  domain_name = module.terrahouse_aws.cloudfront_url
  #domain_name = "geoijol.cloudfront.net"
  town ="missingo"
  content_version = 1
}