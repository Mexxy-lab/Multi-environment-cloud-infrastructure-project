module "network" {
  source = "../../modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Deploy compute only when this environment explicitly enables it.
module "compute" {
  count  = var.enable_compute ? 1 : 0
  source = "../../modules/compute"

  # Reuse the network created by this environment's network module.
  environment = var.environment
  vpc_id      = module.network.vpc_id
  subnet_id   = module.network.public_subnet_ids[0]

  # Keep compute sizing configurable without changing the module.
  instance_type = var.instance_type
  instance_name = "mctp-${var.environment}-app-01"
}