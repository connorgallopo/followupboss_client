#!/bin/bash

# Get API key from .env file
API_KEY=$(grep FUB_API_KEY .env | cut -d '=' -f2)

if [ -z "$API_KEY" ]; then
  echo "Error: FUB_API_KEY not found in .env file"
  exit 1
fi

echo "Using API Key: ${API_KEY:0:4}...${API_KEY: -4}"
echo ""

# Format according to docs - API key is the password, not the username
AUTH_HEADER="authorization: Basic $(echo -n ":${API_KEY}" | base64)"
echo "Auth header: $AUTH_HEADER"

# Make the API request to events
echo ""
echo "Making API request to GET /events..."
curl -s -v --url 'https://api.followupboss.com/v1/events?limit=10&offset=0' \
     --header 'accept: application/json' \
     --header "$AUTH_HEADER" | jq .

# Try people endpoint
echo ""
echo "Making API request to GET /people..."
curl -s -v --url 'https://api.followupboss.com/v1/people?limit=1' \
     --header 'accept: application/json' \
     --header "$AUTH_HEADER" | jq .
