# Getting Comfortable with Terraform and Terraform Cloud

This week started out with the usual live stream that starts up our week.

- [Static Web Page](#static-web-page)
      - [403 Error](#403-error)
- [Serve the Static Website on Cloudfront](#serve-the-static-website-on-cloudfront)
    + [Create distribution](#create-distribution)
      - [403 Error](#403-error-1)
    + [Create Origin Access Control (OAC)](#create-origin-access-control--oac-)
    + [Attach the OAC](#attach-the-oac)
    + [Create new Distribution.](#create-new-distribution)
    + [Attach Bucket Policy](#attach-bucket-policy)
      - [Served page on Cloudfront](#served-page-on-cloudfront)

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
