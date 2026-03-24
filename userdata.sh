#!/bin/bash

yum install amazon-cloudwatch-agent -y

sleep 10

yum install nginx -y

systemctl enable nginx
systemctl start nginx

echo "Hello from application" > /usr/share/nginx/html/index.html

sleep 5

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "metrics": {
       "append_dimensions": {
            "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
        },
        "metrics_collected": {
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s