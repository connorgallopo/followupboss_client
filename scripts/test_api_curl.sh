#!/bin/bash

# Get API key from .env file
API_KEY=$(grep FUB_API_KEY .env | cut -d '=' -f2)

if [ -z "$API_KEY" ]; then
  echo "Error: FUB_API_KEY not found in .env file"
  exit 1
fi

echo "Using API Key: ${API_KEY:0:4}...${API_KEY: -4}"
echo ""

# Make the API request
echo "Making API request to GET /people..."
curl -s -v -u "${API_KEY}:" "https://api.followupboss.com/v1/people?limit=1" | jq .

# Try GET /users as an alternative
echo ""
echo "Making API request to GET /users..."
curl -s -v -u "${API_KEY}:" "https://api.followupboss.com/v1/users?limit=1" | jq .

# Try a different basic auth format 
echo ""
echo "Trying alternative auth format..."
AUTH_HEADER="Authorization: Basic $(echo -n "${API_KEY}:" | base64)"
echo "Auth header: $AUTH_HEADER"
curl -s -v -H "$AUTH_HEADER" "https://api.followupboss.com/v1/people?limit=1" | jq .
