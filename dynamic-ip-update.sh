#!/bin/bash

echo "Cloudflare dynamic IP setter version 0.1"

# Variable check
ERROR=""
if [ -z "$X_AUTH_EMAIL" ]; then
  echo "Require X_AUTH_EMAIL: Username. (e.g. johnappleseed@example.com)"
  ERROR="1"
fi
if [ -z "$X_AUTH_KEY" ]; then
  echo "Require X_AUTH_KEY: API key. (e.g. 123abc456def789ghi)"
  ERROR="1"
fi
if [ -z "$ZONE" ]; then
  echo "Require ZONE: Zone name. (e.g. example.com)"
  ERROR="1"
fi
if [ -z "$DOMAIN" ]; then
  echo "Require DOMAIN: domain name. (e.g. www.example.com)"
  ERROR="1"
fi
if [ -z "$DEVICE" ]; then
  echo "Require DEVICE: ethernet device. (e.g. eth0)"
  ERROR="1"
fi
if [ -n "$ERROR" ]; then
  echo 'usage: X_AUTH_EMAIL="johnappleseed@example.com" X_AUTH_KEY="123abc456def789ghi" ZONE="example.com" DOMAIN="www.example.com" DEVICE="eth0" dynamic-ip-update.sh'
  exit 1
fi

# Get Global IP address
GLOBAL_IP_V4=$(curl --interface $DEVICE -s -X GET http://v4.ipv6-test.com/api/myip.php)
echo "Your global IPv4 is $GLOBAL_IP_V4"
GLOBAL_IP_V6=$(curl --interface $DEVICE -s -X GET http://v6.ipv6-test.com/api/myip.php)
echo "Your global IPv6 is $GLOBAL_IP_V6"$'\n'

# Get zones
echo "Getting zone records..."$'\n'
JSON=$(curl -s -X GET https://api.cloudflare.com/client/v4/zones -H "X-Auth-Email: $X_AUTH_EMAIL" -H "X-Auth-Key: $X_AUTH_KEY" -H "Content-Type: application/json")

# Get zone id
echo "Serching $ZONE zone..."
ZONE_ID=$(echo $JSON | jq -r ".result[] | select(.name == \"$ZONE\") | .id")
echo "$ZONE zone id is $ZONE_ID""."$'\n'

# Get records
echo "Getting zone records..."$'\n'
JSON=$(curl -s -X GET https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records -H "X-Auth-Email: $X_AUTH_EMAIL" -H "X-Auth-Key: $X_AUTH_KEY" -H "Content-Type: application/json")

# Get domain a record id
echo "Serching $DOMAIN A record..."
RECORD_ID=$(echo $JSON | jq -r ".result[] | select(.name == \"tndl.net\") | select(.type == \"A\") | .id")
echo "$DOMAIN A record id is $RECORD_ID""."$'\n'

# Set IP Address
echo "Recode update in progress..."
RESULT=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID -H "X-Auth-Email: $X_AUTH_EMAIL" -H "X-Auth-Key: $X_AUTH_KEY" -H "Content-Type: application/json" --data "{\"type\": \"A\", \"name\": \"$DOMAIN\", \"content\": \"$GLOBAL_IP_V4\", \"proxied\": true}" | jq -r ".result")
echo "cloudflare server says: $RESULT"$'\n'

# Get domain aaaa record id
echo "Serching $DOMAIN AAAA record..."
RECORD_ID=$(echo $JSON | jq -r ".result[] | select(.name == \"tndl.net\") | select(.type == \"AAAA\") | .id")
echo "$DOMAIN AAAA record id is $RECORD_ID""."$'\n'

# Set IP Address
echo "Recode update in progress..."
RESULT=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID -H "X-Auth-Email: $X_AUTH_EMAIL" -H "X-Auth-Key: $X_AUTH_KEY" -H "Content-Type: application/json" --data "{\"type\": \"AAAA\", \"name\": \"$DOMAIN\", \"content\": \"$GLOBAL_IP_V6\", \"proxied\": true}" | jq -r ".result")
echo "cloudflare server says: $RESULT"$'\n'

echo "Script is done!"$'\n'
