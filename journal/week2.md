# Launching and Connecting our Terra house to TerraTowns

We started out this week by creating a mock server for Terratowns, we needed a mock server to use in rapidly testing out our APIs as we create our custom provider.

# TerraTowns Mock Server

The code for our custom provider i located in the [Terratowns mock server repo](https://github.com/ExamProCo/terratowns_mock_server) and tghe first thing we need to do is to download the repo so we can easily work with the code.

To do this we run the below command:

```sh
git clone https://github.com/ExamProCo/terratowns_mock_server.git
```

The next thing we need to do is to delete the `.git` directory in the just downloaded repo.

```sh
cd terratowns_mock_server
rm -rf .git
```

I then added the necessary configuration to my `gitypod.yml` and my `postCreateCommand.sh` files.

In the `gitpod.yml` file
```yml
  - name: sinatra
    before: | 
      cd $PROJECT_ROOT
      cd terratowns_mock_server
      bundle install
      bundle exec ruby server.rb 
```

In the `postCreateCommand` file

```sh
# Navigate to the project root, Navigate to the Sinatra application directory Install dependencies & start the Sinatra server
cd "$PROJECT_ROOT"
cd "terratowns_mock_server"
bundle install
bundle exec ruby server.rb
```

The `bundle install` command will install ruby packages and the `bundle exec ruby server` command will start up the ruby server for us.

I renamed the bin directory in the `terratowns_mock_server` directory to `terratowns` and moved this folder into the `bin` directory in the top level.

I did this because that directory contains all scripts we would use to build our terratowns mock server.

I then made all the scripts in that directory executable, instead of doing it one at a time for all the scripts in the directory I used one command that applied to all the scripts at once:

```sh
chmod u+x bin/terratown/*
```

This command simply says, apply this permission to all the files in this directory.

### Running the web server

We can run the web server by executing the following commands:

```rb
bundle install
bundle exec ruby server.rb
```

All of the code for our server is stored in the `server.rb` file.

# Sinatra

The application we are using for our mock server is Sinatra. 

Sinatra is a micro web application or web framework written in Ruby for building out web apps. We are using it because it is lightweight and it is easy to mock it.

If we need to modify anything it will be pretty simple.

Its great for mock or development servers or for very simple projects.

You can create a web-server in a single file.

https://sinatrarb.com/

## Working with Ruby

As earlier mentioned, our web server sinatra is written in ruby. 

In Ruby it is not compulsory to add () at the end of functions when calling them.

### Bundler

Bundler is a package manager for runy.
It is the primary way to install ruby packages (known as gems) for ruby.

#### Install Gems

You created a Gemfile where we defined our gems.

```rb
source "https://rubygems.org"

gem 'sinatra'
gem 'rake'
gem 'pry'
gem 'puma'
gem 'activerecord'
```

Then you need to run the `bundle install` command

This will install the gems on the system globally (unlike nodejs which install packages in place in a folder called node_modules)

A Gemfile.lock will be created to lock down the gem versions used in this project.

# Mock Server code explanation 

We will mock having a state or database for this development server by setting a global variable. You would never use a global variable in production server.


# Terratowns Provider

Now that we have our mock server worki ng as we need it to, it is time to bui,d our terraform provider.

This provider will be written in golang.

I started by inputting the below code, to test our golang

```golang
package main

import "fmt"

func main() {
	// Format.PrintLine
	fmt.Println("Hello, world!")
}
```

>Package main: Declares the package name. The main package is special in Go, it's where the execution of the program starts.

>fmt is short format, it contains functions for formatted I/O.

>func main(): Defines the main function, the entry point of the app. When you run the program, it starts executing from this function.

Unlike Ruby, go file are complied as binaries. They are not dynamically ran, you don't run the scripts you compile it into a binary and you run the binary.

We run it with the below command:

```golang
go run main.go
```

![Run golang](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/add22496-54a9-4c26-9502-d25ebc1d07a5)

>Golang doesn't have classes, they have things called interfaces.

Command to build the terraform provider

```sh
go build -o terraform-provider-terratowns_V1.0.0
```

# Build Provider Script

We wrote a script to enable me automate the build of our custom provider. The contents of the script can be seen below:

```sh
#!/usr/bin/bash

PLUGIN_DIR="/home/gitpod/.terraform.d/plugins/local.providers/local/terratowns/1.0.0/"
PLUGIN_NAME="terraform-provider-terratowns_v1.0.0"

# https://servian.dev/terraform-local-providers-and-registry-mirror-configuration-b963117dfffa
cd $PROJECT_ROOT/terraform-provider-terratowns
cp $PROJECT_ROOT/terraformrc /home/gitpod/.terraformrc
rm -rf /home/gitpod/.terraform.d/plugins
rm -rf $PROJECT_ROOT/.terraform
rm -rf $PROJECT_ROOT/.terraform.lock.hcl
go build -o $PLUGIN_NAME
mkdir -p $PLUGIN_DIR/x86_64/
mkdir -p $PLUGIN_DIR/linux_amd64/
cp $PLUGIN_NAME $PLUGIN_DIR/x86_64
cp $PLUGIN_NAME $PLUGIN_DIR/linux_amd64
```

I made the script executable and then ran the script.

# Configure the Library in our Terraform

Now that we have the library built out, we need to configure it in our terraform and so we head on the the `main.tf` file in the top level.

I then commented out all the code that was previously in the file and add the below into it in other to specify our provider in our project:

```tf 
terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
}

provider "terratowns" {
  endpoint = "http://localhost:4567"
  user_uuid="e328f4ab-b99f-421c-84c9-4ccea042c7d1" 
  token="9b49b3fb-b8e9-483c-b703-97ba88eef8e0"
}
```

I then went ahead to run `tf init` and `tf plan` commands to verify that m configuration works.