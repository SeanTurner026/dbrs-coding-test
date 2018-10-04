# DRBS Coding Test

To deploy the EC2 Instance running the Jupyter Server, do the following:

Create a file called `terraform.tfvars`. Save this file in `dbrs-coding-test/deploy`. The file must contain the two following key value pairs

```
access_key = "your-aws-access-key"
secret_key = "your-aws-secret-key"
```
An ssh key must also be created and placed in the `dbrs-coding-test/deploy` directory. This can be accomplished with the following command:

```
$ ssh-keygen -q -f aws_terraform -C aws_terraform_ssh_key -N ''
```

The contents of the ssh public key must also be place inside `terraform.tf`. Copy the contents revealed by the below command, and paste in __line 71__.

```
$ cat aws_terraform.pub
```

The user in `terraform.tf` on __line 14__ must also be changed. Add in your own user name

```
    users = [
        "your-aws-username"
    ]
```

Given that all of the above was completed, the following commands will bring the EC2 Instance online and launch the Jupyter Server.

``` bash
$ cd deploy
$ terraform init
$ terraform apply
# deploy.sh clones the repo to the EC2 instance, installs docker, and starts the jupyter server container on the EC2 instance
$ ./deploy.sh
$ ssh -i aws_terraform ubuntu@$EC2_PUBLIC_DNS
# ssh into jupyter/datascience-notebook container from EC2 Instance
$ sudo docker exec -it <container-id> /bin/bash
$ jupyter notebook list
```

From there, copy the token to clipboard, Open a browser and navigate to $EC2_PUBLIC_DNS:8888, and enter the token
