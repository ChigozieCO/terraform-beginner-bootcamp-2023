# Getting Comfortable with Terraform and Terraform Cloud

This week started out with the usual live stream that starts up our week.

- [Static Web Page](#static-web-page)
  - [403 Error](#403-error)
- [Serve the Static Website on Cloudfront](#serve-the-static-website-on-cloudfront)
    + [Create distribution](#create-distribution)
      - [403 Error](#403-error-1)
    + [Create Origin Access Control (OAC)](#create-origin-access-control-oac)
    + [Attach the OAC](#attach-the-oac)
    + [Create new Distribution.](#create-new-distribution)
    + [Attach Bucket Policy](#attach-bucket-policy)
      - [Served page on Cloudfront](#served-page-on-cloudfront)
- [Root Module Structure](#root-module-structure)
- [Restructure Root Module of our Project](#restructure-root-module-of-our-project)
- [Variables in Terraform Cloud](#variables-in-terraform-cloud)
- [Migrate State File to Local Environment From Terraform Cloud](#migrate-state-file-to-local-environment-from-terraform-cloud)
- [`terraform.tfvars`](#terraformtfvars)
- [How to recover when you lose your Statefile.](#how-to-recover-when-you-lose-your-statefile)
    + [Fix Missing Resources with Terraform Import](#how-to-recover-when-you-lose-your-statefile)
      - [See the Official Documentation](#see-the-official-documentation)
      - [AWS S3 Bucket Import Documentation](#aws-s3-bucket-import-documentation)
- [Remove Random Provider](#remove-random-provider)
    + [Import Random String from Random Provider](#import-random-string-from-random-provider)
      - [Official documentation](#official-documentation)
    + [Delete Random Provider](#delete-random-provider)
- [Undeclared Variable Error](#undeclared-variable-error)
    + [Declare Variable `bucket_name`](#declare-variable-bucket_name)
- [Configuration Drift](#configuration-drift)
- [Nested Modules](##nested-modules)
- [Referencing Modules in Configuration (Module Sources)](#referencing-modules-in-configuration-module-sources)
- [Terraform Refresh](#terraform-refresh)
- [S3 Static Website Hosting](#s3-static-website-hosting)
  - [`modules/terraform_aws/outputs.tf`](#modulesterraform_awsoutputstf)
  - [`terraform-beginner-bootcamp-2023/outputs.tf`](#terraform-beginner-bootcamp-2023outputstf)
- [Putting Objects into S3 via Terraform](#putting-objects-into-s3-via-terraform)
- [Working with Files in Terraform](#working-with-files-in-terraform)
    + [Fileexists function](#fileexists-function)
    + [Filemd5](#filemd5)
    + [Path Variable](#path-variable)
- [Terraform Console](#terraform-console)
- [Website Files](#website-files)
- [Declare the Website File Variable](#declare-the-website-file-variable)
  -  [`terraform-beginner-bootcamp-2023/variables.tf`](#terraform-beginner-bootcamp-2023variablestf)
  -  [`.tfvars` File](#tfvars-file)
- [Terraform Data Sources](#terraform-data-sources)
- [Terraform Locals](#terraform-locals)
- [Working with JSON](#working-with-json)
- [CDN Implementation in Terraform](#cdn-implementation-in-terraform)
- [Setup Content Version](#setup-content-version)
    + [Ignore file Changes with Terrafrom Lifecycle](#ignore-file-changes-with-terraform-lifecycle)
    + [Terraform Data](#terraform-data)

# Static Web Page

We created an S3 bucket that would host our static web page, after creating the AWS S3 bucket I turned on static web hosting with index document located at `index.html` and error document located at `error.html`.

Now we need to create the index page and the error page.

First to be able to serve the page locally, I just entered a random html code into the `html.index` page and in the terminal I ran the below code to be able to serve the page locally:

```sh
npm install http-server -g
```

Once that is done, to serve it we need to run the below command:

```sh
http-server
```

Then make it public by clicking on the `make public` button that appears.

![Live http-server](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/c74bac5b-3eb0-4113-b469-cca5b8d86b77)

Now we will push our index file to our s3 bucket via the aws cli

```sh
aws s3 cp public/index.html s3://154f4e38-a1ac-42da-9c20-ad7a5ccfcfe1
-tfbootcamp/index.html
```

When I refresh my bucket I can see that my file has been uploaded to the bucket.

#### 403 Error

However, navigating to the URL of the static page I get a 403 error because by default my bucket is not public, this is a security feature if AWS.

![403 Error](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/db93b2a7-3c30-4ad8-9060-d2a3c0576fd6)

To allow public access to my bucket, I need to navigate to the permissions tab of the bucket and edit the `block public access` section. I also need to add a bucket policy.

However, instead of granting public access this way, we will create a cloudfront distribution as I will be serving the bucket through cloudfront a content distribution network.

# Serve the Static Website on Cloudfront

### Create distribution

- I navigate to cloudfront and click on `create new cloudfront distribution`.

- For the origins I will use the S3 bucket's website endpoint (basically the domain name of the website).

I left all the other options as the default selection.

- For Web Application Firewall (WAF) I selected `Do not enable security protections`

- In the `Default root object` segment I entered `index.html`

- I then added a description as `Terrahouse example cdn`

- Now I went ahead and created the distribution.

When I click into the distribution I can see the Distribution domain name and this is the domain name that will be used to access the static website going forward.

![First Distribution](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/930c9060-7b0f-44a2-a14b-89142698c23d)

#### 403 Error

So I copy the Distribution domain name and navigate to my browser and paste it in but I still have a 403 error.

![403 Error 2](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/3ea966bc-be4e-4b2d-a4cc-7fe1e751b584)

Upon further investigation I can see that the reason why I have this error is because I do not have an `origin access control` and a `bucket policy`. So I have to make those for this bucket.

### Create Origin Access Control (OAC)

- To do this I navigate to `origin access`.

- On the left pane of cloudfront and click on `create control setting`. 

- I enter the name I'd like to use and leave everything else as default 

- And click create.

### Attach the OAC

- To attach the newly created OAC, I navigate to the distribution.

- Click on the `behaviours` tab.

- Select the available behaviour and click `edit`

I had to pivot at this point because I couldn't find how to attach the OAC so we went the route of disabling the first distribution and creating a new one.

### Create new Distribution.

In the creation of this new distribution I didn't use the website's endpoint, I used the S3 bucket name. This allowed me the option on selecting `Origin access control settings` as my origin access.

We found out that when you use the website endpoint as the origin domain (as was done with the first distribution I created above) I didn't have the `origin access` section available to me.

- From the dropdown of the `Origin access control settings` I chose the OAC I created above.

And applied the remaining settings I used in creating the first distribution.

### Attach Bucket Policy

After creating the new distribution I can see a bucket policy that has been created for me and all I need to do is to attach the policy to the bucket so that my website will be accessible now.

![2nd Distribution](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/363d853a-2b8d-4965-b98b-59f885db3302)

- Either follow the provided link, as seen in the screenshot above or navigate to the bucket, click into it and click on the permissions tab.

- Scroll down to the `bucket policy` section and click on edit.

- Once the interface loads, paste the policy you copied from the distribution creation (shown in the screenshot above).

- Click `save changes`.

#### Served page on Cloudfront

Now I when I enter the distributions domain name in my browser I can see m website being served by cloudfront.

![Static web page](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/cb25c20e-f15e-4ba5-a90c-4e3dd2175e5e)

# Root Module structure

When creating terraform modules it is always best to divide your code into different directories that serve different purposes so that all our code is not muddled up in one folder.

This helps the readability of your code is makes it more portable.

To this effect, our project is going to be organised in the following way:

```

PROJECT_ROOT
│
├── main.tf                 # All other configuration.
├── variables.tf            # Stores the structure of input variables
├── terraform.tfvars        # The data of variables we want to load into our terraform project
├── providers.tf            # Defines required providers and their configuration
├── outputs.tf              # Stores our outputs
└── README.md               # Required for root modules
```

Here is the official documentation of [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) of terraform projects. It gives a more comprehensive breakdown of what type of code each folder should contain.

# Restructure Root Module of our Project

Taking the root module structure as we have stated above, I now go ahead to restructure the root module of my own project.

I started out by creating the additional `tf` files I needed, which were:

- outputs.tf
- providers.tf
- variables.tf
- terraform.tfvars

Starting with the `providers.tf` I removed the providers configuration from the `main.tf` file and added them in the `providers.tf` file.

Next I took out the outputs configuration that was in the `main.tf` file and added it to the `outputs.tf` file.

In other to be able to demonstrate the usefulness of the `variables.tf` file I added a tag to my bucket configuration in the `main.tf` file.

In `main.tf` I included the below block of code:

```tf
  tags = {
    UserUuid = var.user_uuid
  }

```

In my `variables.tf` file I include the following code block:

```tf
variable "user_uuid" {
  description = "The UUID of the user"
  type        = string
  validation {
    condition        = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.user_uuid))
    error_message    = "The user_uuid value is not a valid UUID."
  }
}
```

With this configuration in place I encountered errors while running the `tf plan` command 

![Error](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/754440de-3fe6-4c52-a288-325865977a34)

This happened because there are no variables set in my `terraform.tfvars` file and because my state file is saved in terraform cloud it will not read my local files even if I were to input the vaerible in the `terraform.tfvars` file.

A way around this will be to add the variable along with the `tf plan` command as shown below:

```sh
tf plan -var user_uuid='newvariable!'
```

This command will also throw an error because in my `variables.tf` we wrote a validation check that will ensure that the entered variable is in the format which we specified in the validation rule. And this variable entered is clearly not the same format as what it expects.

![Another error](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/972820db-43c6-4329-afe7-dfd0ccaf7ded)

# Variables in Terraform Cloud 

From the image above you can see that the command actually threw two errors, the first I just explained above. The second error however is as a result of my terraform cloud not having the required access to my aws account because I have not supplied it with my aws credentials.

To resolve this error I have to head to terraform cloud and give it the necessary permissions.

These are the steps required to do this:

- Login to [terraform cloud](terraform.io)

- Navigate to your workspace, the workspace for the project you are working on.

- On the left hand pane click on the `variables` option.

- When the page loads fully click on `add variable`

- You will see that uou have two options `Terraform variable` & `Environment variable`. We can do this either ways but I will be setting mine as an `Environment variable`. So I click on that option.

- This will open a form for you to enter you key and the value. Enter `AWS_ACCESS_KEY_ID` in the key column and your actual aws access key id in the value column.

- Click the box at the end that says sensitive so that your access key id is not exposed.

- Then click on `add variable`. 

These last 4 instructions are demonstrated in the image below.

![Configuration sequence](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/b13edd5e-6031-40b7-8fd7-924af6542bc9)

- Repeat this same process to add your `AWS_SECRET_ACCESS_KEY` and your default variable, for the default variable you can leave the sensitive unchecked if you please cos this value is not sensitive.

At the end your terraform cloud should look like this (with any other env var you might have added)

![Terraform cloud variables](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/035ef123-d8d3-4f9d-bfbb-19ed8335b5ab)

# Migrate State File to Local Environment From Terraform Cloud

Before I continue, we decided to migrate our state file from the cloud back to our local environment but before we do that we will first tear down the infrastructure to avoid having duplicates.

First thing I did was to comment out all the new configurations added, which is basically the variable.tf and the tags.

Now that I have already added my AWS credentials to my terraform cloud I can run `terraform destroy` and the command would run without errors.

After destroying the infrastructure, to migrate the state file from the cloud all I have to do is to comment out the code block that contains `cloud`, `organisation`, `workspace` and `name`.

Next I then delete my `.terraform.lock.hcl` file and my `.terraform` directory and run `terraform init` again.

# `terraform.tfvars`

 This is where you store your variables for your project. If your state file is stored locally your environment will read this file to populate your code with the value of the env var that is called in the configuration. 
 
 This file should never be committed. It has been added to my `.gitignore` file so I won't make the mistake of committing it because most often than not it will contain senstive data.

Eg of how you store variables in it:

```tf
user_uuid="154f4e38-a1ac-42da-9c20-ad7a5ccfcfe1"
```

Now wherever terraform sees `user_uuid` called in my c onfiguration it will subsititute it with the value in the `terraform.tfvars` file. This helps keep secrets secret.

I also went ahead and added this user_uuid and the value to my terraform cloud variables, as a Terraform Variable, so that whenever I am working from the terraform cloud I already have that value saved there.

# How to recover when you lose your Statefile. 

If you lose your statefile, you will most likely have to tear down all your cloud infrastructure manually.

You can use terraform import but it won't for all cloud resources. You need check the terraform providers documentation for which resources support import.

If you have a lot of resources in your terraform configuration you might not be able to recover everything with terraform import because not all resources allow import. 

The general rule is to make sure you store your statefile somewhere like terraform cloud or an S3 bucket.

### Fix Missing Resources with Terraform Import

The command to use is:

```sh
terraform import aws_s3_bucket.bucket bucket-name
```

![terraform import](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/8ec03200-bbe1-4908-adda-5373d4b0c786)

#### See the Official Documentation 
[Terraform Import](https://developer.hashicorp.com/terraform/cli/import)

#### AWS S3 Bucket Import Documentation
[AWS S3 Bucket Import](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)

Running the above command will import the S3 bucket and create a statefile for us.

# Remove Random Provider

Now that I have a statefile I run the `tf plan` command to see the behaviour of terraform, I am trying to test out whether or not terraform will recognise that my configuration is in its correct state.

However I notice that because of my use of the random provider, terraform is now trying to tear down the existing bucket and build a new one with a new name.

![random provider](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/4ecd58ed-9315-45b5-bffe-8941407164ae)

This will be a problem in an instance where you do not want the bucket torn down and so we would stop making use of the random provider in our configuration.

### Import Random String from Random Provider 

Before taking out the random provider we try to import random string to see if that will fix our issue.

The command we used:

```sh
terraform import random_string.bucket_name <bucket name>
```

#### Official documentation

[Import Random String](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string#import)

This however doesnt fix our issue so we still go ahead and take out the random provider in our configuration.

### Delete Random Provider

So I go to my `providers.tf` file and delete the random provider code block.

I also take out the `random_string` code block in the `main.tf` file.

In the `aws_s3_bucket` resource I edit the bucket line (the line that has the bucket name) with the variable of the bucket name as I will be adding the bucket name to my `terraform.tfvars` file.

```tf
...
bucket = var.bucket_name
```

Then I add the value of the bucket_name as a variable in the `terraform.tfvars` file.

# Undeclared Variable Error

Now when I run `terraform plan` again I still have an error. This error occurs because we have not defined the variable in the `variable.tf` file. Whenever we have a variable we need to declare it in the `variables.tf` file.

![undeclared variable](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/25075be6-5b4c-48f8-b1ac-511134a218b3)

Error one is explained above. I will resolve it by declaring my `bucket_name` variable in the `variables.tf` file.

Error two occurs because I still have my `random_bucket_name` as a value I would want terraform to output after builing my infrastructure when I am no longer using the random provider.

The solution to resolving this error is simply to delete that line of code from my `outputs.tf` file.

### Declare Variable `bucket_name`

Now I will declare the variable `bucket_name` in the `variables.tf` file along with a validation for it with the code below:

```hcl
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string

  validation {
    condition     = (
      length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && 
      can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "The bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and can contain only lowercase letters, numbers, hyphens, and dots."
  }
}
```

In the `outputs.tf` file, I delete the previous code there and replaced with the below:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}
```

In the `main.tf` I changed the bucket name in the `aws_s3_bucket` resource from example to website_bucket which the bucket name value points to in the outputs.tf.

When I run terraform plan I do not run into any error.

# Configuration Drift

Configuration drift is when the configuration of an environment “drifts”, or in other words, gradually changes, and is no longer consistent with an organization's requirements. 

Configuration drift happens when changes to software and hardware are made ad hoc, without being recorded or tracked.

Configuration drift as it relates to terraform refers to when your infrastructure is different from what is states in your statefile. Your statefile is designed to accurately tell what resources you having in your cloud environment at any point and in the correct state it is in.

If someone goes and delete or modifies cloud resource manually through ClickOps while the statefile still exists, terraform will know and rebuild that resource when next you run `terraform apply`

If we run `terraform plan` it with attempt to put our infrstraucture back into the expected state fixing Configuration Drift.

# Nested Modules

Terraform modules are self-contained packages of Terraform configurations that are managed as a group. You can create modules for each project you are working on and they are very reusable if configured properly.

It is recommend to place modules in a `modules` directory when locally developing modules but you can name it whatever you like.

To begin I created the directory structure I will be using for my Module.

The directory structure is shown below:

```
modules
└── terrahouse_aws
    ├── LICENSE
    ├── main.tf
    ├── outputs.tf
    ├── README.md
    └── variables.tf
```

Now I will isolate the inner infrastructure, which is basically my bucket, and any other thing related to storage.

We want them in its own file. Everything related to a delivery will be located in it's own file.

I moved my previous configuration from the files they were in previously (`main.tf`, `variables.tf`, `variables.tf`) into their respective files in the `terrahouse_aws` module.

# Referencing Modules in Configuration (Module Sources)

After moving my infrastructure into the nested module, I need a way to refernce them in the general infrastructure. I do this by calling the module in the configuration in the `main.tf` file outside the module. As shown below:

```tf
module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.user_uuid
  bucket_name = var.bucket_name
}
```

You should note that we can call our modules from different sources, using the source we can import the module from various places eg:
- locally
- Github
- Terraform Registry

In the above sample code block, I imported my module from a local source.

[Modules Sources](https://developer.hashicorp.com/terraform/language/modules/sources)

With my configuratgion in place the next thing I did was to validate the accuracy of my configuration.

I can do this by either running the `terraform validate` command or the `terraform plan` command. I chose to use the latter.

After running the plan command, I discover that I have some errors.

![errors](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/176a0998-7623-4901-a213-4715fb821708)

This error is as a result of not having our variables declared in the top level, even though we have it declared in the module we still need to declare it in the top level.

This is what I now do by adding the following code blocks in the `variable.tf` file in the top level.

```tf
variable "user_uuid" {
    type = string
}

variable "bucket_name" {
    type = string
}
```

Here I didn't make it as elaborate as before because I have already done that at the module level where I added the necessary validator checks.

Running the plan command again and I can see that trhere are no more errors.

Now I apply my changes by running the `tf apply` command.

Although my deploy was successful I realised I had no outputs, this was because, just as with the case lf the variables, I need to also have an `outputs.tf` file declaring the outputs I wants in my top level just as I did in the module.

Therefore, in the `outputs.tf` file at the top level in include the following code:

```tf
output "bucket_name" {
  description = "Bucket name for our static website hosting"
  value = module.terrahouse_aws.bucket_name
}
```

# Terraform Refresh

The `terraform refresh` command reads the current settings from all managed remote objects and updates the Terraform state to match. This command is deprecated though.

This won't modify your real remote objects, but it will modify the Terraform state.

You shouldn't typically need to use this command, because Terraform automatically performs the same refreshing actions as a part of creating a plan in both the `terraform plan` and `terraform apply` commands.

The way to use the command uis shown below:

```sh
terraform apply -refresh-only -auto-approve
```

# S3 Static Website Hosting

At the beginning of this week we learnt how to setup Static Website hosting via ClickOps however now we will repeat that whole process using terraform.

The below code is the configuration for the S3 Static Website Hosting:

```tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
```

Now I run the `terraform plan` command to check the accuracy and visualise the plan for our infrastructure.

Seeing that everything is in order, I ran the `tf apply` command to deploy the infrastructure.

I then added configuration to output the website endpoint.

#### `modules/terraform_aws/outputs.tf`

```tf
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}
```

#### `terraform-beginner-bootcamp-2023/outputs.tf`

```tf

output "s3_website_endpoint" {
  description = "S3 Static Website hosting endpoint"
  value = module.terrahouse_aws.website_endpoint
}
```

# Putting Objects into S3 via Terraform

The configuration to put objects into your S3 bucket via terrafrom is shown below:

```tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key = index.html
  source = var.index_html_filepath

  etag = filemd5(var.index_html_filepath)
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "error.html"
  source = var.error_html_filepath

  etag = filemd5(var.error_html_filepath)
}
```

The above code was added to the `main.tf` file of my module.

# Working with Files in Terraform

There are various ways we can work with files in terraform. They include:

### Fileexists function

This is a built in terraform function to check the existance of a file.

```tf
condition = fileexists(var.error_html_filepath)
```

https://developer.hashicorp.com/terraform/language/functions/fileexists

### Filemd5

This is a function that will create a hash based on the contents of the file. So if the contents of the file changes, the hash also changes.

https://developer.hashicorp.com/terraform/language/functions/filemd5

We use this in our configuration so that terraform can pick up the changes in our file even if the configuration remains the same. 

This is necessary because terraform only detects changes in the statefile, if changes are made to a file alone the statefile has no way of registering this change unless you make use of the etag with the `filemd5` function.

Now when the hash changes, the value of the etag will change in the statefile and terraform will know there's been a change somewhere.

we used this in our configuration, in the `aws_s3_object` block as shown below:

```tf

  etag = filemd5(var.index_html_filepath)
```

### Path Variable

In terraform there is a special variable called `path` that allows us to reference local paths:
- path.module = get the path for the current module
- path.root = get the path for the root module
[Special Path Variable](https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info)


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "index.html"
  source = "${path.root}/public/index.html"
}

# Terraform Console

Terraform console is an interactive way to troubleshoot and debug stuff in terraform. It can simply be run with the command:

```sh
terraform console
```

# Website Files

I created a new directory called `public` that will house our two website files `index.html` and `error.html`. As seen:

```
public
├── error.html
└── index.html
```

# Declare the Website File Variable

Instead of encoding the filepaths of our website files, we decided to declare then as variables.

And so as we have been doing from the beginning of this project, we first declare the variable in the module's variable.tf file.

#### `modules/terraform_aws/variables.tf`

```tf
variable "index_html_filepath" {
  description = "The file path for index.html"
  type        = string

  validation {
    condition     = fileexists(var.index_html_filepath)
    error_message = "The provided path for index.html does not exist."
  }
}

variable "error_html_filepath" {
  description = "The file path for error.html"
  type        = string

  validation {
    condition     = fileexists(var.error_html_filepath)
    error_message = "The provided path for error.html does not exist."
  }
}
```

#### `terraform-beginner-bootcamp-2023/variables.tf`

In the variables.tf file of the top directory I added the below code:

```tf
variable "index_html_filepath" {
  type = string
}

variable "error_html_filepath" {
  type = string
}
```

#### `.tfvars` File

I also added these codes to the `terraform.tfvars` and the `terraform.tfvars.example` in the top directory.

```tf
index_html_filepath="/workspace/terraform-beginner-bootcamp-2023/public/index.html"
error_html_filepath="/workspace/terraform-beginner-bootcamp-2023/public/error.html"
```

Now I go ahead and apply my changes. You can see my uploaded buckets below.

![S3 Objects](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/d62d5f06-56e5-4533-9904-f3c2a5121123)

# Terraform Data Sources

Data sources allow Terraform to use information defined outside of Terraform, defined by another separate Terraform configuration, or modified by functions.

A data source is accessed via a special kind of resource known as a data resource, declared using a data block shown below.

This allows use to source data from cloud resources.

This is useful when we want to reference cloud resources without importing them.

```tf
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

[Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)

# Terraform Locals

Locals allows us to define local variables.
It can be very useful when we need transform data into another format and have referenced a varaible.

```tf
locals {
  s3_origin_id = "MyS3Origin"
}
```
[Local Values](https://developer.hashicorp.com/terraform/language/values/locals)

# Working with JSON

We use the jsonencode to create the json policy inline in the hcl.

```tf
> jsonencode({"hello"="world"})
{"hello":"world"}
```

[jsonencode](https://developer.hashicorp.com/terraform/language/functions/jsonencode)

# CDN Implementation in Terraform

To create the cloudfront distribution via terraform we created two new file `resource-cdn.tf` and `resource-storage.tf`. These files were created so that each resource group has its own file and the `main.tf` file does not get too crowded making it hard to read.

The contents of the files:

- [resource-cdn.tf](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/blob/3c2c56a078138a18e9660fd8ac8e2063b8ca7055/modules/terrahouse_aws/resource-cdn.tf)
- [resource-storage.tf](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/blob/3c2c56a078138a18e9660fd8ac8e2063b8ca7055/modules/terrahouse_aws/resource-storage.tf)

The image below shows the deployed cdn and the working site.

![Tf CLI](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/c0c85d01-67b5-4e3c-af8a-0619f2cbd687)

![Deployed cdn](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/9ef05679-6eb0-4182-9408-00e52b5e4705)

![cdn domain name](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/cb755c85-c46e-45bc-834d-d7844fdd3cff)

![Static website](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/ac5d9727-55f7-4b14-b6cb-1f457528f6bd)

# Setup Content Version

Now we have cloudfront setup and the s3 bucket setup and serving a website however we would like it to invalidate the cache when files change.

We want cloudfront to only cache when we want it to explicitly cache and we will do that by setting a content version.

I started by adding a `content_version` variable as shown below:

```tf

variable "content_version" {
  description = "The content version. Should be a positive integer starting at 1."
  type        = number

  validation {
    condition     = var.content_version > 0 && floor(var.content_version) == var.content_version
    error_message = "The content_version must be a positive integer starting at 1."
  }
}
```

I also added this variable at the top level:

```tf
variable "content_version" {
  type        = number
}

I then added the variable to my `.tfvars` file

```tf
content_version=var.content_version
```

In our `main.tf` file on the top level we added the content_version variable.

### Ignore file Changes with Terraform Lifecycle

Although we added the etag in other for terraform to know when there is a change in our website documents we do not want the infrasdtructure to change everytime there is a change in those documents. We only want this change to happen when there is a change in the content version.

We will ignore the etag changes by adding the `ignore_changes` flag in the `lifecycle` function.

Lifecycle is a nested block that can appear within a resource block. The lifecycle block and its contents are meta-arguments, available for all resource blocks regardless of type.

https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

This is how we used it:

```tf
  lifecycle {
    ignore_changes = [etag]
  }
```

### Terraform Data

Now any change we make to the documents will not we applied to our infrastructure but this is not exactly what we want because we need changes to be applied when there is a content version change.

And so we will need to add another flag to the lifecycle.

Before then though, we need to tie over content version to a resource because we can't directly put the content version in the lifecycle.

To achieve what we need we will use `terraform data`.

Plain data values such as Local Values and Input Variables don't have any side-effects to plan against and so they aren't valid in replace_triggered_by. You can use terraform_data's behavior of planning an action each time input changes to indirectly use a plain value to trigger replacement.

https://developer.hashicorp.com/terraform/language/resources/terraform-data

We will add this to the `resource-storage.tf` file in our module, as seen below:

```tf
resource "terraform_data" "content_version" {
  input = var.content_version
}
```

Now to apply the trigger so it triggers when tere is a change in the content version we add the below line of code to our lifecycle:

```tf
    replace_triggered_by = [terraform_data.content_version.output]
```

# Invalidate Cache in the Cloudfront Distribution via Terraform

There really isn't a way to invalidate cacheeith the latest AWS provider so we will and so we will use the terraform data. 

Using `null resource` was the old way of doing it, `terraform data` is the new way of doing it.

Terraform data is a better way of doing it because it doesn't require you to install a provider, we don't have to pull anything down.

The idea here is that we want to have it in place so that when there is a change to our file or our content version, the content version will trigger a provisionmal `local exec` which is going to run a cli command locally to invalidate the cache.

To implement this, we will put the configuration in our `resource-cdn.tf` file:

```tf
resource "terraform_data" "invalidate_cache" {
  triggers_replace = terraform_data.content_version.output

  provisioner "local-exec" {
    # https://developer.hashicorp.com/terraform/language/expressions/strings#heredoc-strings
    command = <<COMMAND
aws cloudfront create-invalidation \
--distribution-id ${aws_cloudfront_distribution.s3_distribution.id} \
--paths '/*'
    COMMAND

  }
}
```

When you invalidate cache, you can tell it to feed exactly the files you want via json file but we're not doing that because it is complicated and we don't have a lot of files in this project and that is why we used the forward slash asterisks (/*).

A good/correct workflow would just validate only the files you want to validate.

# Provisioners

Provisioners allow you to execute commands on compute instances eg. a AWS CLI command.

They are not recommended for use by Hashicorp because Configuration Management tools such as Ansible are a better fit, but the functionality exists.

[Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax)

:warning: :warning:

Provisioners like local exec and remote exec are discouraged from being used because there are other tools that can do the job like anisible but in practice a lot of companies are probably still using it.

>**Local exec**
Local exec runs on the local machine that is doing the terraform commands and so if we move it to terraform cloud , the local machine will where ever terraform cloud's compute is. 

eg 
```tf
resource "aws_instance" "web" {
  # ...
  provisioner "local-exec" {
    command = "echo The server's IP address is ${self.private_ip}"
  }
}
```

>**Remote exec** allows you to point to some external compute and you can give it the ability to log in via SSH with additional configurations and execute it that way. It will execute commands on a machine which you target.

eg 

```tf
resource "aws_instance" "web" {
  # ...
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web.private_ip}",
    ]
  }
}

https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
```

The reason it is not recommended is that terraform is not a configuration management tool, we just save our statefile there.


