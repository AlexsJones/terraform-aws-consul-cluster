#!/bin/bash
sudo yum update -y
#Add aws cli
sudo yum install -y awslogs
# Install Docker, add ec2-user, start Docker and ensure startup on restart
yum install -y docker
usermod -a -G docker ec2-user
service docker start
chkconfig docker on

# A few variables we will refer to later...
ASG_NAME="${asgname}"
REGION="${region}"
EXPECTED_SIZE="${size}"

# Return the id of each instance in the cluster.
function cluster-instance-ids {
    # Grab every line which contains 'InstanceId', cut on double quotes and grab the ID:
    #    "InstanceId": "i-example123"
    #....^..........^..^.....#4.....^...
    aws --region="$REGION" autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME \
        | grep InstanceId \
        | cut -d '"' -f4
}

# Return the private IP of each instance in the cluster.
function cluster-ips {
    for id in $(cluster-instance-ids)
    do
        aws --region="$REGION" ec2 describe-instances \
            --query="Reservations[].Instances[].[PrivateIpAddress]" \
            --output="text" \
            --instance-ids="$id"
    done
}

# Wait until we have as many cluster instances as we are expecting.
while COUNT=$(cluster-instance-ids | wc -l) && [ "$COUNT" -lt "$EXPECTED_SIZE" ]
do
    echo "$COUNT instances in the cluster, waiting for $EXPECTED_SIZE instances to warm up..."
    sleep 1
done

# Get my IP address, all IPs in the cluster, then just the 'other' IPs...
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
mapfile -t ALL_IPS < <(cluster-ips)
OTHER_IPS=( $${ALL_IPS[@]/{$IP}/} )
echo "Instance IP is: $IP, Cluster IPs are: $${ALL_IPS[@]}, Other IPs are: $${OTHER_IPS[@]}"

# Start the Consul server.
docker run -d --net=host \
    --name=consul \
    consul agent -server -ui \
    -bind="$IP" \
    -client="0.0.0.0" \
    -retry-join="$${OTHER_IPS[0]}" -retry-join="$${OTHER_IPS[1]}" \
    -retry-join="$${OTHER_IPS[2]}" -retry-join="$${OTHER_IPS[3]}" \
    -bootstrap-expect="$EXPECTED_SIZE"
