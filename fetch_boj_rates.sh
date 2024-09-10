#!/bin/bash

set -euo pipefail  # Exit immediately on error, treat unset variables as an error, and fail on pipe errors

# Define variables
URL="https://boj.org.jm/market/foreign-exchange/indicative-rates/"
TOKEN_FILE="/tmp/token.txt"  # Temporary file to store the token
CURL_URL="https://boj.org.jm/wp-admin/admin-ajax.php?action=get_wdtable&table_id=135"
OUTPUT_FILE="bojfxrates.json"  # Output file

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to get the token and save it to a file
get_token() {
    log "Attempting to fetch a new token from $URL"
    # Download the webpage using curl
    html_content=$(curl -s "$URL")
    
    # Extract the value of the input whose id starts with wdtNonceFrontendServerSide_
    nonce_value=$(echo "$html_content" | grep -o '<input[^>]*id="wdtNonceFrontendServerSide_[^"]*"[^>]*value="[^"]*"' | sed -n 's/.*value="\([^"]*\)".*/\1/p')
    
    # Check if the value was found
    if [ -n "$nonce_value" ]; then
        echo "$nonce_value" > "$TOKEN_FILE"
        log "Token obtained and saved: $nonce_value"
    else
        log "Error: Token could not be obtained."
        exit 1
    fi
}

# Function to perform the request
perform_request() {
    local token="$1"
    
    log "Performing request with token: $token"
    response=$(curl -s -o "$OUTPUT_FILE" -w "%{http_code}" -X POST "$CURL_URL" \
      -H "accept: application/json, text/javascript, */*; q=0.01" \
      -H "accept-language: en-US,en;q=0.8" \
      -H "content-type: application/x-www-form-urlencoded; charset=UTF-8" \
      -H "origin: https://boj.org.jm" \
      -H "referer: https://boj.org.jm/market/foreign-exchange/indicative-rates/" \
      -H "sec-ch-ua: \"Not)A;Brand\";v=\"99\", \"Brave\";v=\"127\", \"Chromium\";v=\"127\"" \
      -H "sec-ch-ua-mobile: ?0" \
      -H "sec-ch-ua-platform: \"macOS\"" \
      -H "sec-fetch-dest: empty" \
      -H "sec-fetch-mode: cors" \
      -H "sec-fetch-site: same-origin" \
      -H "sec-gpc: 1" \
      -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" \
      -H "x-requested-with: XMLHttpRequest" \
      --data "action=get_wdtable&table_id=135&draw=2&columns[0][data]=0&columns[0][name]=date&columns[0][searchable]=true&columns[0][orderable]=true&columns[0][search][value]=%7C&columns[0][search][regex]=false&columns[1][data]=1&columns[1][name]=currency&columns[1][searchable]=true&columns[1][orderable]=true&columns[1][search][value]=U.S.%20DOLLAR&columns[1][search][regex]=true&columns[2][data]=2&columns[2][name]=buying&columns[2][searchable]=false&columns[2][orderable]=false&columns[2][search][value]=&columns[2][search][regex]=false&columns[3][data]=3&columns[3][name]=selling&columns[3][searchable]=true&columns[3][orderable]=false&columns[3][search][value]=&columns[3][search][regex]=false&order[0][column]=0&order[0][dir]=desc&start=0&length=25&search[value]=&search[regex]=false&wdtNonce=$token&sRangeSeparator=%7C")
    
    if [ "$response" -eq 200 ]; then
        log "Request successful. Output saved to: $OUTPUT_FILE"
        return 0
    else
        log "Request failed with status code: $response"
        return 1
    fi
}

# Main logic
if [ ! -f "$TOKEN_FILE" ]; then
    log "Token file not found. Getting a new one..."
    get_token
fi

# Read the token from the file
nonce_value=$(cat "$TOKEN_FILE")

# Try the initial request
if ! perform_request "$nonce_value"; then
    log "Retrying with a new token..."
    get_token
    nonce_value=$(cat "$TOKEN_FILE")
    
    # Retry the request with the new token
    if ! perform_request "$nonce_value"; then
        log "Error: Request failed even after obtaining a new token."
        exit 1
    fi
fi

log "Script completed successfully."
