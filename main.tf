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
  cloud {
    organization = "TheChigozieCO"
    workspaces {
      name = "terra-house-1"
    }
  }
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid= var.teacherseat_user_uuid
  token= var.terratowns_access_token
}
module "home_beaches_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.beaches.public_path
  content_version = var.beaches.content_version
}

resource "terratowns_home" "beaches" {
  name = "Escape the chaos, come relax at the beach"
  description = <<DESCRIPTION
We all know how stressful the rat race can be so we all need 
somewhere to go and relax and unwind.
Here are the most relaxing and calming beaches you should visit.
Start by taking in the scenery, relaxation is sure to start from here.
Hope to see you at one of these places in the nearest future.
  DESCRIPTION
  domain_name = module.home_beaches_hosting.domain_name
  #domain_name = "geoijol.cloudfront.net"
  town ="missingo"
  content_version = var.beaches.content_version
}

module "home_gadgets_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.gadgets.public_path
  content_version = var.gadgets.content_version
}

resource "terratowns_home" "gadgets" {
  name = "Gadgets that make your life easier"
  description = <<DESCRIPTION
Over here we're about quality life and so we bring you the best
to help you have the best quality of life. I will bring ou the most 
useful gadgets you didn't even know you needed and they will make you
question how you have managed to live you life, up until now, without
them. Stay tuned.
  DESCRIPTION
  domain_name = module.home_gadgets_hosting.domain_name
  #domain_name = "staywokeyy.cloudfront.net"
  town ="missingo"
  content_version = var.gadgets.content_version
}