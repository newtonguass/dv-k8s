#!/bin/bash
ip=$(curl -s http://ipinfo.io/ip)
echo '{"ip":"'${ip}'"}'  | jq