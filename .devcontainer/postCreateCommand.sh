#!/usr/bin/env bash

# Install Terraform CLI, Generate tfrc credentials & set tf alias for codespace

source ./bin/install_terraform_cli_codespace
source ./bin/generate_tfrc_credentials
source ./bin/set_tf_alias
cp $PROJECT_ROOT/terraform.tfvars.example $PROJECT_ROOT/terraform.tfvars


      
      
      
      
