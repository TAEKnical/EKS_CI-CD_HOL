resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc_main.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
}

resource "aws_vpc_endpoint_route_table_association" "pub_sub_to_s3" {
#   count             = length(local.public_subnets)
  vpc_endpoint_id   = aws_vpc_endpoint.s3.id
  route_table_id    = aws_route_table.public.id
}

# resource "aws_vpc_endpoint_route_table_association" "pri_sub_to_s3" {
#   count = length(aws_nat_gateway.nat_gw)
#   vpc_endpoint_id   = aws_vpc_endpoint.s3.id
#   route_table_id    = aws_route_table.private[count.index].id
# }
