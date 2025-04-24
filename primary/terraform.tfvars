# vpc
region              = "eu-west-1"
vpc_cidr            = "11.0.0.0/16"
vpc_name            = "primary_vpc"
cidr_public_subnet  = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet = ["11.0.3.0/24", "11.0.4.0/24"]
availability_zones  = ["eu-west-1a", "eu-west-1b"]

# security group
alb_sg_name         = "dr-alb-sg"
ec2_sg_name         = "dr-ec2-sg"
db_sg_name          = "dr-database-sg"
security_group_cidr = "0.0.0.0/0"

# database
db_password       = "rootpassword"
db_username       = "root"
db_name           = "todo_list"
db_instance_class = "db.t3.micro"
db_identifier     = "todo-db"
db_subnet_name    = "primary-subnet-group"
db_engine         = "mysql"
storage_type      = "gp2"

# alb
project_name = "dr-project"
#route53
domain_name = "faithlab.site"
alternative_names = ["www.faithlab.site"]

# EC2 VARIABLES
instance_name = "todo-list-app"
key_name      = "lampstack"


# Database secret name:

db_secret_name = "prod/live/real2"