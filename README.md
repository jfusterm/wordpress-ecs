
# Wordpress on ECS

Practical example on how to get a Wordpress running under an Amazon ECS Cluster using different technologies.

## Technologies

* [Wordpress](https://wordpress.org/)
* [Packer](https://www.packer.io/)
* [Docker](https://www.docker.com/)
* [Ansible](https://www.ansible.com/)
* [Terraform](https://www.terraform.io/)
* [Amazon ECS](https://aws.amazon.com/ecs/)
* [Amazon RDS](https://aws.amazon.com/es/rds/)
* [Amazon ELB](https://aws.amazon.com/elasticloadbalancing/)

## Requirements

To use this example you will need an [AWS](https://aws.amazon.com/es/) account and:

* [Packer](https://www.packer.io/downloads.html)
* [Terraform](https://www.terraform.io/downloads.html)
* [Docker](https://docs.docker.com/engine/installation/)

## Usage

1. Build the Wordpress container.

Packer will use a [base Docker image with Ansible](https://github.com/titanlien/wordpress-ecs/blob/master/Dockerfile) to provision all the applications needed to run a Wordpress. The result will be saved into a container named `titanlien/wp-packer` with a version tag `4.7.3`.

**Note 1**: If you want to change the image tag you have to change it in `wp-packer.json` and `wordpress.json`.

**Note 2**: Packer will push the image to [Dockerhub](https://hub.docker.com/) automatically.


```
# packer build -var 'DOCKER_PASSWD=[SECURITY]' wp-packer.json
```

Check that the image is ready.

```
# docker images

REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
titanlien/wp-packer   4.7.3               334cf6396987        16 hours ago        155 MB
```

2. Deploy all the infrastructure needed on AWS using Terraform.
3. Create two amazon roles, *qq-ecs-role* and *qq-ec2-role*, to handle the EC2 resource.
4. Launching stack by following command.
```bash
$ env TF_VAR_aws_access_key=$AWS_ACCESS_KEY TF_VAR_aws_secret_key=$AWS_SCERET_KEY TF_VAR_key_name=titan@MBA terraform apply
```

Once deployed, Terraform will print out the ECS Container Instances public IPs and the [ELB](https://aws.amazon.com/es/elasticloadbalancing/) URL that will distribute the traffic across the different Wordpress container instances.

The RDS connection parameters will be passed on runtime to the Wordpress containers via environment variables.

5. Upstream container log to cloudwatch awslogs.

6. Once not needed, we can remove all the AWS infrastructure:


```bash
$ terraform destroy
```

## Considerations

This example uses a basic and simple approach to get a ready to use Wordpress using different technology. Further modifications will be done to get a fully automated, scalable and high available Wordpress. Some thoughts:

* Wrap all the steps in a single script: build the container, push the container to Dockerhub or a private registry and finally deploy all the infrastructure on AWS.
* Distribute the ECS Container Instances across different availability zones and route the traffic using the ELB among them.
* Decouple Nginx and PHP-FPM in separate containers so can be scaled independently.
* Sending log to [ELK](https://www.elastic.co/products) or [Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/).
* Setting [cloudwtach](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/mon-scripts.html) to monitor CPU, memory and network traffic.
* Use a shared or distributed storage system to persist Wordpress' data. Examples:
    * [Amazon EFS](https://aws.amazon.com/efs/)
    * [GlusterFS](https://www.gluster.org/)
    * [Flocker](https://docs.clusterhq.com/en/latest/docker-integration/)
* Remove the RDS single point of failure. Examples:
    * Deploy RDS on [Multi-AZ](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
    * Use [Percona XtraDB Cluster](https://www.percona.com/software/mysql-database/percona-xtradb-cluster)

## Sample ELB page
![alt text][demo]

[demo]: https://github.com/titanlien/wordpress-ecs/raw/master/raw/images/wp-demo.png "Wordpress Title Text 2"
