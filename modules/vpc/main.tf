resource "random_pet" "this" {
  length = 2
}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "vpc-${random_pet.this.id}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "igw-${random_pet.this.id}" }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 100 + count.index) # Offset to avoid overlap
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 1)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# NAT Gateway (1 per region - in first AZ public subnet)
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat-${random_pet.this.id}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "public-rt-${random_pet.this.id}"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "private-rt-${random_pet.this.id}"
  }
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


## VPC Endpoint Code

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

locals {
  endpoint_services = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "ecr.api",
    "ecr.dkr",
    "logs",
    "monitoring"
  ]
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = toset(local.endpoint_services)
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "vpce-${each.key}"
  }
}
resource "aws_vpc_endpoint" "gateway_endpoints" {
  for_each            = toset(["s3", "dynamodb"])
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [aws_route_table.private.id]

  tags = {
    Name = "vpce-${each.key}"
  }
}


resource "aws_ssm_parameter" "vpc_id" {
  name  = "/vpc/id"
  type  = "String"
  value = aws_vpc.this.id
}

resource "aws_ssm_parameter" "private_subnets" {
  count = var.az_count
  name  = "/vpc/private_subnets/${count.index}"
  type  = "String"
  value = aws_subnet.private[count.index].id
}

