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

