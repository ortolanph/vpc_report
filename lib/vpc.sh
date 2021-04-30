#!/bin/bash

# AWS Simple VPC functions
# Author: Paulo Henrique Ortolan

# Fectches all the VPCS for a given Profile and Region
function fetch_all_vpcs() {
	VPC_JSON="$OUTPUT_DIR/vpc_list_"$AWS_PROFILE"_"$AWS_REGION".json"
	aws ec2 describe-vpcs --region=$AWS_REGION --profile=$AWS_PROFILE > $VPC_JSON

	VPC_LIST=($( cat $VPC_JSON | jq --raw-output '.Vpcs[].VpcId' ))
}

# Checks if a subnet is public or private
function check_privacy() {
	if [[ "$1" == "true" ]]; then
		echo "public"
	else
		echo "private"
	fi
}

# Describes a subnet
function describe_subnet() {
	SUBNET_DATA=$1

	QUERY_PRIVACY="echo $SUBNET_DATA | jq '.MapPublicIpOnLaunch'"
	PRIVACY=$( check_privacy $( eval $QUERY_PRIVACY) )

	QUERY_NAME="echo $SUBNET_DATA | jq --raw-output '.Tags[] | select(.Key == \"Name\") | .Value' "
	NAME=$( eval $QUERY_NAME )

	QUERY_CIDR="echo $SUBNET_DATA | jq --raw-output '.CidrBlock'"
	CIDR=$(eval $QUERY_CIDR )

	echo "| "$PRIVACY" | "$NAME" | "$CIDR" |"
}

# Describes all the subnets for a given VPC
function describe_subnets() {
	VPC=$1
	SUBNETS_JSON="$OUTPUT_DIR/subnets_"$AWS_PROFILE"_"$AWS_REGION"_"$VPC".json"
	aws ec2 describe-subnets --filters "Name=vpc-id,Values=\"$VPC\"" --region=eu-central-1 > $SUBNETS_JSON

	TOTAL_SUBNETS=$( cat $SUBNETS_JSON | jq '.Subnets | length' )
	BOUNDARY_SUBNETS="$(($TOTAL_SUBNETS - 1))"
	INDEXES=($(seq 0 $BOUNDARY_SUBNETS))

	if [ $BOUNDARY_SUBNETS -ge 0 ]; then
		echo "| Privacy | Name | CidrBlock |"
		echo "|:-------:| ---- |:---------:|"

		for INDEX in "${INDEXES[@]}"
		do
			QUERY_SUBNET="cat $SUBNETS_JSON | jq '.Subnets[$INDEX]'"
			SUBNET=$( eval $QUERY_SUBNET )
			describe_subnet '$SUBNET'
		done
	else
		new_line
		bold "No subnets registered"
		new_line
	fi
}

# Describes a Given VPC
function describe_vpc() {
	VPC=$1

	QUERY_VPC_NAME="cat $VPC_JSON | jq --raw-output '.Vpcs[] | select(.VpcId == \"$VPC\") | .Tags[] | select(.Key == \"Name\") | .Value'"
	VPC_NAME=$( eval $QUERY_VPC_NAME)

	QUERY_VPC_CIDR_BLOCK="cat $VPC_JSON | jq --raw-output '.Vpcs[] | select(.VpcId == \"$VPC\") | .CidrBlock'"
	VPC_CIDR_BLOCK=$( eval $QUERY_VPC_CIDR_BLOCK)

	h2 $VPC_NAME
	bullet_field "VPC Id" "$VPC"
	bullet_field "CIDR Block" "$VPC_CIDR_BLOCK"
	new_line

	h3 "Subnets"

	describe_subnets $VPC

	new_line
}

# Describes all the VPCS found by Region and Profile
function describe_vpcs() {
	for VPC in "${VPC_LIST[@]}"
	do
		describe_vpc $VPC
	done
}
