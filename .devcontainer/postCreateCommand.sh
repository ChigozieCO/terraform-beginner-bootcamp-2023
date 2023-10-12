#!/usr/bin/env bash

# Install Terraform CLI, Generate tfrc credentials & set tf alias for codespace
source ./bin/install_terraform_cli_codespace
source ./bin/generate_tfrc_credentials
source ./bin/set_tf_alias_codespace
cp $PROJECT_ROOT/terraform.tfvars.example $PROJECT_ROOT/terraform.tfvars

# Install AWS ClI
source ./bin/install_aws_cli_codespace
source ./bin/set_tf_alias_codespace

# Install Http Live Server
npm install --global http-server

# Navigate to the project root, Navigate to the Sinatra application directory Install dependencies & start the Sinatra server
cd "$PROJECT_ROOT"
cd "terratowns_mock_server"
bundle install
#bundle exec ruby server.rb
      
      
      
