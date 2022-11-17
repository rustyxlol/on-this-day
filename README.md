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
6. `docker run -d -p ...`
7. Use the instance's **public ip**, make sure its `HTTP`

**Without Docker**  
Instead of installing docker, we'll be installing Apache server and host `dist` folder on it. So build the project locally and move the `dist` folder to `/var/www/html`  
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
