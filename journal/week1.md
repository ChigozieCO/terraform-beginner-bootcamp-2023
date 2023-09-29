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

```hcl
  tags = {
    UserUuid = var.user_uuid
  }

```

In my `variables.tf` file I include the following code block:

```hcl
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

```hcl
user_uuid="154f4e38-a1ac-42da-9c20-ad7a5ccfcfe1"
```

Now wherever terraform sees `user_uuid` called in my c onfiguration it will subsititute it with the value in the `terraform.tfvars` file. This helps keep secrets secret.

I also went ahead and added this user_uuid and the value to my terraform cloud variables, as a Terraform Variable, so that whenever I am working from the terraform cloud I already have that value saved there.





