# on-this-day

## Introduction

On This Day is a minimalist Vue3 application made for getting my hands dirty with DevOps methodolgoy and tooling.

## Table of Contents

- [on-this-day](#on-this-day)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Day 1 - Vue](#day-1---vue)
    - [Creating a minimalist Vue application](#creating-a-minimalist-vue-application)
    - [Notes](#notes)
  - [Day 2 - Docker](#day-2---docker)
    - [Dockerizing the Vue application](#dockerizing-the-vue-application)
    - [Notes](#notes-1)
  - [Day 3 - AWS IAM and EC2](#day-3---aws-iam-and-ec2)
    - [Dockered EC2 Notes](#dockered-ec2-notes)
    - [Apache Server Notes](#apache-server-notes)
    - [Backup and Restore](#backup-and-restore)
    - [Notes](#notes-2)
  - [Day 4 - Terraform](#day-4---terraform)
    - [Notes](#notes-3)
  - [Day 5 - Terraform and AWS](#day-5---terraform-and-aws)
    - [Notes](#notes-4)
  - [Day 6 - Terraform and AWS Continued](#day-6---terraform-and-aws-continued)
    - [Notes](#notes-5)
  - [Day 7 - Ansible](#day-7---ansible)

## Day 1 - Vue

### Creating a minimalist Vue application

The birth of on-this-day application, I spent a day learning little bit of Vue3 and setting up minimum viable product that not only looked neat but also contained enough functionality for it to be classified as a web-application. I'll add more features as the journey continues.

Why Vue you ask? I just wanted something that required interacting with CLI in order to be able to use DevOps tools like Terraform, Github Actions, and AWS. And it isn't react so that's an added bonus.

### Notes

1. Instead of Vue CLI, I went for plain old `npm init vue@latest`

## Day 2 - Docker

### Dockerizing the Vue application

Successfully containerized the Vue application and made sure the pages were being served from the build, rather than the development environment. *And pushed it to Docker hub!*  

**TODO:** docker-compose

---

### Notes

1. Docker desktop is pretty nice
2. Why would O'Reilly take KataCoda down? :(

## Day 3 - AWS IAM and EC2

I had already created an AWS account a long ago but some things weren't setup properly so I decided that this was the perfect time to finish the stuff that I left off previously.

1. Enabled MFA for root user
2. Removed all existing active access key for the root user
3. Created an admin user with `AdministratorAccess` policy so that I don't have to use the root user for accessing my account outside AWS
4. Downloaded and setup AWS CLI with the admin user, works flawlessly. Also why are my secret access key and ID stored in plaintext?? To check what user is using CLI, just use `aws iam get-user`

---

Now that accounts and permissions are out of the way, what's remaining is to host this little application on an EC2 instance.  
There are two approaches to this  

**With Docker**  
This is pretty straightforward, launch an EC2 instance, install Docker on that instance, start docker service, pull the image and voila, you've got it!  
Oh and make sure to open your ports in the security group!  

### Dockered EC2 Notes

1. Use `yum update` and `sudo amazon-linux-extras install docker` to install docker
2. Start docker `sudo service docker start`
3. Add user to group `sudo usermod -a -G docker ec2-user`
4. Logout and login
5. `docker pull ...`
6. `docker run -d -p 5000:8080 ...`
7. Use the instance's **public ip**, make sure its `HTTP`

**Without Docker**  
Instead of installing docker, we'll be installing Apache server and host `dist` folder (or whatever the folder you got after running building the project). So build the project locally and move the `dist` folder to `/var/www/html`  
Make sure your security group isn't blocking anything here as well.

### Apache Server Notes

1. Download Apache server first,  `sudo yum -y install httpd`
2. Run the server, `sudo service httpd start`
3. Give privileges to the /var/www/html folder
4. Copy local files to `/var/www/html` using scp `scp -i "path/to/key" -r dist/* ec2-user@65.0.182.123:/var/www/html`
5. Restart the server `sudo service httpd restart`
6. Use the instance's **public ip**, make sure its `HTTP`

---

### Backup and Restore

Rather small topic which I didn't want to save until next day. The task here is to basically take a snapshot of the current EC2 instance, delete it and redeploy it from the snapshot.

1. Go to volumes, create a snapshot of the volume of your EC2 instance
2. Go to snapshots and create an AMI from the snapshot you created
3. Go to AMIs and launch instance from the AMI you created
4. Make sure to start `httpd` and ensure that the website is still online

You can run `sudo service httpd start` when creating an instance by just putting the command in user data when creating an instance.

For reference:

```sh
#!/bin/bash -xe

sudo service httpd start
```

---

### Notes

1. General syntax for AWS-CLI is basically `aws [service] [command]`, so something like `aws ec2 describe-instances` will give you a list of all instances based on format you specified during `aws configure`
2. IAM is incredibly complex, the reason we don't see the complexity is because we're barely working with one or two services.
3. While creating an instance and stuff is point and click, IaaS services like Terraform can be used to automate the entire process of creating an instance and populating it.

## Day 4 - Terraform

Infrastructure as Code comes in three flavors; configuration, application and provisioning. Terraform is for provisioning resources on the Cloud(or even locally). It felt quite easy to get into and understand but I believe the hard part of it is yet to come.

So far I've learnt about basic provisioning and some nomenclature

**Programs covered today:**

1. Creating and managing a local file
2. Understanding input and output variables
3. Different datatypes in Terraform
4. Running a container

### Notes

1. Terraform has a very neat nomenclature, as in:  
`resource "local_file" "tf_hello_file"`  
the syntax is as follows:  
`resource "<provider>_<resource>" "identifier"`  
2. Refer to the documentation for getting all the supported arguments for a given resource, in this case it was `local` provider and the resource was `file`
3. Terraform contains a bunch of types; string, number, bool, any, list, map, set, object and tuple
4. `-var` arg takes the highest precedence, followed by `.auto.tfvars`, then `.tfvars` and finally environment variables
5. When doing implicit dependency(associating one resource with another using interpolation), code might not look clean. In order to obtain explicit dependency, one must use `depends_on` argument in the resource which requires another resource
6. One can use output block to see output variables after using `apply`, and one can see the output variables using `terraform output`, or a specific output using `terraform output <output_variable>`
7. Output variables are for other IaC tools like Ansible
8. `.tfstate` contains your metadata, perhaps don't touch it unless you know what you're doing. Terraform refreshes state everytime, so you can use `--refresh=false` argument when planning/applying
9. `.tfstate` is for collaboration, everyone must have the latest `.tfstate` file so store it REMOTELY if collaborating
10. `.tfstate` contains some sensitive information so try to keep it in a secure storage e.g. S3, TF Cloud
11. Some commands:
    1. `terraform fmt` - formats
    2. `terraform show` - shows current state of infrastructure
    3. `terraform providers` - shows all providers
    4. `terraform providers mirror /path/to/other/directory` - copies plugins/providers to other directory
    5. `terraform output` - all outputs
    6. `terraform output <output_variable>`
    7. `terraform refresh` - syncs state file
    8. `terraform graph` - generates a dependency graph for visualization software like graphviz

12. Terraform has lifecycle argument which helps you establish an order of apply or re-apply, for example: in a resource -  ```lifecycle { prevent_delete = true}```
13. You can also specify `ignore_changes` in lifecycle to prevent terraform from applying changes, like AWS instance names(tags)
14. Data sources are similar to resources but only read infrasturcture and are "logical"
15. Meta arguments: lifecycle, depends_on, for_each.
16. `for_each = toset(var.filename)`, count is similar but creates undesirable results since it creates resources as a **list**

## Day 5 - Terraform and AWS

CloudAcademy has a few cool exercises to make full use of Terraform and AWS, although they provided the solutions, this is a test of exploring the Terraform AWS provider and resources and getting my hands dirty without looking at the solution.

**Exercise 1:** Create a simple AWS VPC spanning 2 AZs. Public subnets will be created, together with an internet gateway, and single route table. A t3.micro instance will be deployed and installed with Nginx for web serving. Security groups will be created and deployed to secure all network traffic between the various components.  

Quite straightforward, do note that creating VPC will create a default route table so if you don't want an extra route table, use the default route table resource!

### Notes

Exercises can be found under terraform folder

## Day 6 - Terraform and AWS Continued

One exercise today as well, it tackles ALB and ASG.

**Exercise 2:** Create an advanced AWS VPC spanning 2 AZs with both public and private subnets. An internet gateway and NAT gateway will be deployed into it. Public and private route tables will be established. An application load balancer (ALB) will be installed which will load balance traffic across an auto scaling group (ASG) of Nginx web servers. Security groups will be created and deployed to secure all network traffic between the various components.

### Notes

Exercises can be found under terraform folder

## Day 7 - Ansible

An introduction to Ansible. It is a flavor of IaC, configuration management. It's quite popular because it is so easily accessible, as long as you have python that is. Simply run `pip3 install ansible` and voila, you have it!

Some of the introductory stuff I did today are:

1. Ping an EC2 instance by configuring public IP and ssh keypair in the inventory and overriding the ansible defaults so that running ansible refers to the inventory file that I made `ansible example -m ping`
2. Running ad-hoc commands, such as `ansible example -a "free -h"`, or `ansible example -a "date"`
3. Difference between `-a` and `-m`, `-m command` is the default, which basically runs a command ON the server
