#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

yum update -y
yum install -y amazon-cloudwatch-agent

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "ec2-system-logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s