# Week 0 - Prerequisite Week

It's time to get this show on the road :dancers: :dancers:

This is the beginning of the Terraform project bootcamp and so we need to carry out some housekeeping to setup everything we need for the bootcamp.

# Register Terraform Cloud

As I already have an AWS account created, the first thing I did was create a terraform cloud account with the following steps.

- I navigated to the [Terraform site](https://www.terraform.io/)
- Click on the Try Terraform Cloud located at the top right side of the site
- Enter my details as required and signup.
- Upon signup, you will be required to enter in the password you just created and verify your account by clicking on the link sent to your mail.
- After verifying the account I can see that my Terraform cloud account has successfull been created.

![Terraform Cloud](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/27a5abcc-1da2-4561-8930-c2cba22f2e8d)


# Install Git Graph

After creating the project template on github using [Andrew Brown's template](https://github.com/ExamProCo/terraform-beginner-bootcamp-2023) we went ahead to install Git Grap, a Vs Code extention that will help us visualise changes we make to our code.

The extenstion is shown below

![Git Graph](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/5c289513-49af-4411-aca3-0781519cfb5f)


# Update Readme

The next thing we did was to update our Readme file to include the documentation of the Semantic Versioning that we would be using for this project.

For this project we will be raising issues and heavily making use of branching to work on the raised issue.

This is necessary in order to better familarise ourselves with good work practice of protecting our main branch by first working in another branch, making the necessary changes there before it is merged into main.

We created our first issue, at first I created my first branch outside the issue and so that branch wasn't tagged with the issue and so I corrected that mistake by creating a new branch under the issue that was tagged with the issue.

The content of the Readme:

```md

# Terraform Beginner Bootcamp 2023

## Semantic Versioning!

This project is going utilize semantic versioning for its tagging.
[semver.org](https://semver.org/)

The general format:

 **MAJOR.MINOR.PATCH**, eg. `1.0.1`

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backward compatible manner
- **PATCH** version when you make backward compatible bug fixes

```

# Tagging and Merging

After making my changes I commited them, tagged and pushed to the branch and then I created a pull request.

The command to create the tag is shown below:

```sh
git tag 0.1.0
```

I also created tag `0.1.1` to correct my inital branching mistake.

The tag was pushed usinmg this command 

```sh
git push --tag
```

As this is a project I am working with on my own I was still the one that reviewed and merged the pull request I created.

Merging this branch with main closed the firat issue I crected.

![Closed issue](https://github.com/ChigozieCO/terraform-beginner-bootcamp-2023/assets/107365067/fa480fc4-1d61-49fd-9919-5eab25173a8a)


# Refactor Terraform CLI 

The next thing we did was to correct the Terraform CLI installation instruction added by the bootcamp instructor.

We noticed that the Terraform CLI installion was not fully automated and required user input to complete the installation, this is not ideal and so we need to fix this.

The first thing I did was to create an issue and create a new branch to this effect.

The issue is named `Refactor Terraform CLI`

The new branch is called `3-refactor-terraform-cli` it is on this branch that we would make all our changes.

We ran our existing terraform installation command line by line to figure out the particular line that had the issue and while at it we discovered that the commands being used are depreciated and so we decided to update the commands to the recent one.

As a result of the new set of commands having a lot of lines of code we decided to make it into a script and add a command to run this new script in the `gitpod.yml` file.

### `bin/install_terraform_cli`

```sh
#!/usr/bin/env bash

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform -y

```

We made use of `#!/usr/bin/env bash` instead of `#!/usr/bin/bash` as the former makes the script more portable with other systems.

For ease of calling the script for execution I need to give the script execution permissions and I do this with the command below

```sh
chmod u+x /bin/install_terraform_cli
```

I then updated my `gitpod.yml` file, I took out the first set of terraform installation commands and replaced with this

```yml
      source ./bin/install_terraform_cli
```

# Project Root Env Vars

We decided to update the bash script to set the project root env var and call it in the script and so the following lines of code was added to the `install_terraform_cli` bash script.

```sh

cd /workspace

...
...

cd PROJECT_ROOT
```

Then I set the env var and persisted it on gitpod.

```sh
export PROJECT_ROOT='/workspace/terraform-beginner-bootcamp-2023'
gp env PROJECT_ROOT='/workspace/terraform-beginner-bootcamp-2023'
```

# Refactor AWS CLI Installation

When I restart a previously stopped gitpod workspace, the AWS CLI has issues installing correctly and so in the solution, just like was done for the terraform installation, I will refactor the AWS CLI installation into a bash script.

The firat thing I did was to create a `install_aws_cli` file in the `bin` directory.

The contents of the script

```sh

#!/usr/bin/env bash

cd /workspace

rm -f '/workspace/awscliv2.zip'
rm -rf '/workspace/aws'

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws sts get-caller-identity

cd $PROJECT_ROOT
```

Next I took out the installation instructions in the `gitpod.yml` file and replaced with the command below

```yml
      source ./bin/install_aws_cli
```

Then I made the file executable using the method already shown above.

# Set AWS env vars

To check if what AWS credentials are set or if they are set correctly in your environment, use the below AWS CLI command:

```sh
aws sts get-call-identity
```

To set the AWS credentials and persist on gitpod I do the following

```sh

export AWS_ACCESS_KEY_ID='<your AWS access key id>'
export AWS_SECRET_ACCESS_KEY='<your AWS secret access key>'
export AWS_DEFAULT_REGION='<Your Aws default region>'

gp env AWS_ACCESS_KEY_ID='<your AWS access key id>'
gp env AWS_SECRET_ACCESS_KEY='<your AWS secret access key>'
gp env AWS_DEFAULT_REGION='<Your Aws default region>'
```

I then commited my changes, created a pull request, merged the changes into my main branch and tagged it.

# Terraform Prodivers and Modules - Generate a Random Resource

You need to always remember the [Terraform registry](https://registry.terraform.io/) when working with terraform because this is where you will get the documentation for Terrraform.

In the Terraform registry you will get providers and modules and also examples of how to implement whatever infrastructure you would like to spin up.

Providers in terraform is how you directly interact with an API to make it powered by terraform.

A module is collection of terraform files, it is basically a way of creating a template to utilise commonly used actions. It makes things easier and more portable to move terrafoem code around.

The hashicorp [random provider](https://registry.terraform.io/providers/hashicorp/random/latest) allows us to randomly generate out things out. We will use it to learn.

Using the documentation from the random provider we will write out the module necessary to generate out the random bucket name.

```hcl
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "random" {
  # Configuration options
}

resource "random_string" "bucket_name" {
  length           = 16
  special          = false
}

output "random_bucket_name" {
  value = random_string.bucket_name.result
}
```
### Init

To begin any terraform project, we need to initialize terrafrom in the folder by running the init command:

```sh
terraform init
```

### Plan

We run the plan command to show us the changeset. A changeset is a file that shows the changes that will be implemented when the created or updated module, it tells us was what and what will be onces the changes are implemented. It creates a plan to be implemented.

The command:

```sh
terraform plan
```

### Apply

The apply command will run the plan to generate out the plan and then execute the plan, basically implement the infrastructure buildup.

Apply is run with the below command:

```sh
terraform apply
```

Whenever you run this command terraform will always ask you if you want to carry out thus action, you can either answer yes or no. To avoid this question coming up you can directly include `auto approve` in the command as shown below:

```sh
terraform apply --auto-approve
```

