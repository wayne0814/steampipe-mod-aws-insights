dashboard "vpc_cleanup" {

  title         = "VPC Cleanup Phase 3"

  tags = {
    service = "Xendit"
    type = "Dashboard"
  }

  table {
    title = "VPCs"

    sql   = <<-EOQ
      select
        vpc_id,
        tags->'Name' as name,
        cidr_block,
        is_default,
        (select count(*) from aws_vpc_route_table where vpc_id = aws_vpc.vpc_id) as route_tables,
        (select count(*) from aws_vpc_subnet where vpc_id = aws_vpc.vpc_id) as subnets,
        (select count(*) from aws_ec2_instance where vpc_id = aws_vpc.vpc_id) as ec2_instances,
        (select count(*) from aws_ec2_network_interface where vpc_id = aws_vpc.vpc_id) as enis,
        (
          select
            count(*)
          from
            aws_vpc_vpn_gateway
            cross join jsonb_array_elements(vpc_attachments) as i
          where
            i->>'VpcId' = aws_vpc.vpc_id
        ) as vpn_connections
      from
        aws_vpc
      where
        vpc_id IN (
          'vpc-a8d637ce',
          'vpc-k1alhqtuzyel72dat55o3',
          'vpc-30ac2457',
          'vpc-0de0ac383d0e8d97a',
          'vpc-06164e39ccc135b4e',
          'vpc-0092640405dc00a06',
          'vpc-k1amg2oydc9qehzfps2cr',
          'vpc-09ec81b1b966f099c'
        )
      order by
        cidr_block::text
    EOQ

    column "vpc_id" {
      href = "${dashboard.vpc_detail.url_path}?input.vpc_id={{.'vpc_id' | @uri}}"
    }
  }
}
