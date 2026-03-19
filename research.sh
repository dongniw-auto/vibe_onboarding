#!/bin/bash

# Deep Research API Script
# Usage: ./script.sh ["your custom query"]
# If no query is provided, uses the default query below

URL="https://deepresearch.pokee.ai"
ENDPOINT="deep-research"
AUTH_TOKEN="b22bcde058907394334d14ad4b9c7156a6f70d5c3c011347"

# Default query from website
DEFAULT_QUERY="Evaluate the different AI Agent/vibe coding trends and produce an in-depth study on the pro/cons of each strategy. Then summarize a 7-day step by step onboarding guide. 
"

# Use command-line argument if provided, otherwise use default
if [ -n "$1" ]; then
    USER_QUERY="$1"
    echo "Using custom query: $USER_QUERY"
else
    USER_QUERY="$DEFAULT_QUERY"
    echo "Using default query from website"
fi

# Escape the query for JSON
ESCAPED_QUERY=$(echo "$USER_QUERY" | sed 's/"/\"/g' | tr '
' ' ' | sed 's/  */ /g')
REQUEST_DATA="{
    \"query\": \"$ESCAPED_QUERY\"
}"

echo "Sending request to Deep Research API..."
echo "Note: Deep Research API takes somewhere between 7 to 25 minutes depending on the complexity of the query"
echo "Please wait..."
TASK_RESPONSE=$(curl --location "$URL/$ENDPOINT" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer ${AUTH_TOKEN}" \
--data "$REQUEST_DATA")

echo "$TASK_RESPONSE"

# Generate timestamp prefix
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Save the full response to timestamped JSON file
echo "$TASK_RESPONSE" > "${TIMESTAMP}_response.json"
echo "Saved response to ${TIMESTAMP}_response.json"

# Try to parse as JSON and extract fields
# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required to parse result and save markdown files."
    exit 0
fi

if echo "$TASK_RESPONSE" | jq empty 2>/dev/null; then

    # Extract formatted_outline and save to markdown
    FORMATTED_OUTLINE=$(echo "$TASK_RESPONSE" | jq -r '.output_data.formatted_outline // empty')
    if [ -n "$FORMATTED_OUTLINE" ]; then
        echo "$FORMATTED_OUTLINE" > "${TIMESTAMP}_outline.md"
        echo "Saved outline to ${TIMESTAMP}_outline.md"
    fi

    # Extract formatted_writeup and save to markdown
    FORMATTED_WRITEUP=$(echo "$TASK_RESPONSE" | jq -r '.output_data.formatted_writeup // empty')
    if [ -n "$FORMATTED_WRITEUP" ]; then
        echo "$FORMATTED_WRITEUP" > "${TIMESTAMP}_writeup.md"
        echo "Saved writeup to ${TIMESTAMP}_writeup.md"
    fi
else
    echo "Response is not valid JSON, skipping field extraction"
fi
