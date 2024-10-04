# COSC349 assignment 2 (2024): 

This repository contains the files required to build and deploy an application in the cloud.

## Overview of Application

This application is a bookmark management tool that keeps a collection of website links along with an appropriate short description and tags. So far the functionality of the tool is limited to viewing and editing the bookmarks. 

The application includes the use of 3 AWS services:
- EC2
    - Both the frontend and backend webservers are hosted on their respective EC2 instances.
- RDS
    - A MySQL Relational Database Service is used to hold the bookmark database.
- S3
    - An S3 bucket is used to statically hold the necessary `.css` files that are utilised by the web pages.

## Instructions to Build and Deploy

### Prerequisites

1. Vagrant - `https://developer.hashicorp.com/vagrant/install?product_intent=vagrant`
2. Docker - `https://www.docker.com/products/docker-desktop/`
3. MySQLWorkbench - `https://dev.mysql.com/downloads/workbench/`
4. Access to AWS - `https://aws.amazon.com/`

### Building the application

1. Clone this git repo onto your personal machine: `https://github.com/cheeky489/cosc349-a2.git`
2. Navigate to the cloned repository directory.
3. Then run the following command in the command-line: `vagrant up --provider=docker`
4. SSH into the VM: `vagrant ssh default`
5. Navigate to the shared Terraform directory: `cd /vagrant/tf-deploy`
6. Initialise Terraform
    1. `terraform init`
    2. `terraform plan`
    3. `terraform apply`
    4. Follow prompts
7. Configure ip addresses for frontend and backend web pages (steps apply for both instances):
    1. SSH into the selected instance: `ssh -i ~/.ssh/cosc349-2024.pem ubuntu@{IP}`
    2. Move into the web pages directory: `cd /var/www/html`
    3. Edit the ip address .txt files: `sudo nano frontend_ip.txt`/`sudo nano backend_ip.txt`
8. Open MySQL Workbench to upload data
    1. Open MySQL workbench and add a new connection.
    2. Give the connection a name you prefer.
    3. Choose connection method - `Standard TCP/IP`
    4. Enter your RDS endpoint in the field of Hostname.
    5. Port: `3306`
    6. Username: `webuser`
    7. Password: `lolpassword`
    8. Click Test Connection to make sure you are connected.
    9. Open the connection.
    10. Open the supplied `setup-database.sql` file from workbench.
    11. Run the file and data will be uploaded.
9. Connect the EC2 instances with RDS
    1. From the RDS dashboard, find the created RDS instance.
    2. Under `Connectivity & security`, setup EC2 connections by selecting both EC2 instances.

### Running the Application

Now that the application has been built, you can access the main page from its ip address. Your query should look like this: `{IP}/front-index.php`.

### Cleaning up
From the vagrant helper console run:
1. `terraform destroy` and follow the prompts.
2. Logout of the helper VM: `logout`
3. `vagrant halt`
4. `vagrant destroy`