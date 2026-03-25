# "networking-resources" module includes vpc, subnets, route-table, nat, igw configuration

module "networking-resources" {
    source = "./modules/networking-resources"
    vpc_cidr = var.vpc_cidr
    azs = var.azs
    resource_name = var.resource_name
    environment = var.environment
    cost_center = var.cost_center
}

# "security-resources" module security-groups, ACM, kms, alb-access-log configuration
module "security-resources" {
    source = "./modules/security-resources"
    access_log_bucket_name = var.access_log_bucket_name
    kms_deletion_window_in_days = var.kms_deletion_window_in_days
    domain_name = var.domain_name
    vpc_id = module.networking-resources.vpc_id
    resource_name = var.resource_name
    environment = var.environment
    cost_center = var.cost_center
    depends_on = [ module.networking-resources ]
}

# "auto-scailing-resources" module includes ASG, ALB, Lauch-Temaplate configuration

module "auto-scailing-resources" {
    source = "./modules/auto-scailing-resources"
    vpc_id = module.networking-resources.vpc_id
    alb_subnets = module.networking-resources.public_subnets
    private_subnets = module.networking-resources.private_subnets
    alb_sg = module.security-resources.alb_sg
    ec2_sg = module.security-resources.ec2_sg
    s3_access_logs = module.security-resources.log_bucket
    app_healthcheck_path = var.app_healthcheck_path
    health_check_ineterval = var.health_check_ineterval
    health_check_timeout = var.health_check_timeout
    cert_arn = module.security-resources.cert_arn
    key_name = var.key_name
    ami_id = var.ami_id
    user_data = file("${path.module}/userdata.sh")
    instance_type = var.instance_type
    kms_ebs_key_id = module.security-resources.kms_ebs_key_id
    ebs_volume_size = var.ebs_volume_size
    asg_min_size = var.asg_min_size
    asg_max_size = var.asg_max_size
    asg_desired_size = var.asg_desired_size
    resource_name = var.resource_name
    environment = var.environment
    cost_center = var.cost_center
    depends_on = [ module.networking-resources, module.security-resources ]
}

# "monitoring-resources" module cloudwatch-alarms, sns, budget-alarm, configuration

module "monitoring-resources" {
    source = "./modules/monitoring-resources"
    alert_email = var.alert_email
    target_group_arn_suffix = module.auto-scailing-resources.tg_arn_suffix
    load_balancer_arn_suffix = module.auto-scailing-resources.lb_arn_suffix
    asg_name = module.auto-scailing-resources.asg_name
    depends_on = [ module.auto-scailing-resources ]
}
