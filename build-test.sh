#!/usr/bin/env bash

read -r -d '' PAYLOAD << EOF
{
    "source": {
        "target":"http://10.10.1.101:8080",
        "teams": [
            {
                "name":"prs",
                "password":"concourse",
                "username":"concourse"
            }
        ]
    },
    "params": {
        "config_file":"workspace/pr.yml",
        "method":"create",
        "name":"hello-world",
        "params_file":"workspace/params-pr.yml",
        "should_start":"false",
        "team":"prs"
    }
}
EOF

echo $PAYLOAD | ./assets/out
