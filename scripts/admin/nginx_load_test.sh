#!/bin/bash

set -euo pipefail

# Default values
URL="http://example.com"
CONCURRENT=10
REQUESTS=1000
TIMEOUT=30
VERBOSE=false

# Function to display usage
usage() {
    echo "Usage: $0 [-u URL] [-c CONCURRENT] [-n REQUESTS] [-t TIMEOUT] [-v]"
    echo "  -u URL         Target URL (default: $URL)"
    echo "  -c CONCURRENT  Number of concurrent connections (default: $CONCURRENT)"
    echo "  -n REQUESTS    Total number of requests (default: $REQUESTS)"
    echo "  -t TIMEOUT     Timeout in seconds (default: $TIMEOUT)"
    echo "  -v             Verbose output"
    exit 1
}

# Parse command line options
while getopts "u:c:n:t:vh" opt; do
    case $opt in
        u) URL=$OPTARG ;;
        c) CONCURRENT=$OPTARG ;;
        n) REQUESTS=$OPTARG ;;
        t) TIMEOUT=$OPTARG ;;
        v) VERBOSE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Verify curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it and try again."
    exit 1
fi

# Function to run a single test
run_test() {
    local start_time end_time duration curl_output curl_error
    start_time=$(date +%s.%N)
    curl_output=$(curl -kL -s -o /dev/null -w "%{http_code}|%{time_total}|%{size_download}|%{url_effective}|%{remote_ip}|%{scheme}|%{ssl_verify_result}|%{num_redirects}" -m "$TIMEOUT" "$URL" 2>&1)
    curl_error=$?
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "$curl_output|$duration|$curl_error"
}

# Run the load test
echo "Running load test with the following parameters:"
echo "URL: $URL"
echo "Concurrent connections: $CONCURRENT"
echo "Total requests: $REQUESTS"
echo "Timeout: $TIMEOUT seconds"
echo "Note: SSL certificate validation is disabled"
echo

export -f run_test
export URL TIMEOUT

results=$(seq "$REQUESTS" | xargs -I {} -P "$CONCURRENT" bash -c 'run_test')

# Parse and display results
total_time=$(echo "$results" | awk -F'|' '{sum+=$NF} END {print sum}')
successful_requests=$(echo "$results" | awk -F'|' '$1 >= 200 && $1 < 300 {count++} END {print count}')
failed_requests=$((REQUESTS - successful_requests))

requests_per_second=$(echo "scale=2; $REQUESTS / $total_time" | bc)
avg_time_per_request=$(echo "scale=2; $total_time / $REQUESTS" | bc)

echo "Summary:"
echo "Requests per second: $requests_per_second"
echo "Average time per request: ${avg_time_per_request}s"
echo "Successful requests: $successful_requests"
echo "Failed requests: $failed_requests"

if [ "$failed_requests" -eq 0 ]; then
    echo "The ingress-nginx setup successfully handled all requests."
else
    failure_rate=$(echo "scale=2; $failed_requests / $REQUESTS * 100" | bc)
    echo "Failure rate: ${failure_rate}%"

    echo -e "\nError Details:"
    echo "$results" | awk -F'|' '$1 < 200 || $1 >= 300 {print $0}' | \
        awk -F'|' '{
            printf "HTTP Code: %s, Time: %ss, Size: %s bytes, URL: %s, IP: %s, Scheme: %s, SSL Verify: %s, Redirects: %s, Curl Exit: %s\n",
            $1, $2, $3, $4, $5, $6, $7, $8, $10
        }' | sort | uniq -c | sort -rn | head -10

    if $VERBOSE; then
        echo -e "\nDetailed Curl Output:"
        curl -kLv "$URL" -o /dev/null
    fi

    echo -e "\nDNS Resolution:"
    host $(echo "$URL" | awk -F[/:] '{print $4}')

    echo -e "\nConnection Test:"
    nc -zv -w5 $(echo "$URL" | awk -F[/:] '{print $4}') 443

    echo -e "\nSSL Certificate Info:"
    echo | openssl s_client -showcerts -servername $(echo "$URL" | awk -F[/:] '{print $4}') -connect $(echo "$URL" | awk -F[/:] '{print $4}'):443 2>/dev/null | openssl x509 -inform pem -noout -text
fi
