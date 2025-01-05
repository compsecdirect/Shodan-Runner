#!/bin/dash

clear
cat << 'EOF'
███████╗██╗  ██╗ ██████╗ ██████╗  █████╗ ███╗   ██╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
██╔════╝██║  ██║██╔═══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████╗███████║██║   ██║██║  ██║███████║██╔██╗ ██║██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
╚════██║██╔══██║██║   ██║██║  ██║██╔══██║██║╚██╗██║██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
███████║██║  ██║╚██████╔╝██████╔╝██║  ██║██║ ╚████║██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
EOF

echo 'Version 0.5 / Last Update Jan 2025 / Created by @jfersec'
echo 'https://github.com/compsecdirect/Shodan-Runner'
echo 'License: MIT'

# Function to check if Shodan CLI is installed, install if missing
check_shodan() {
    if ! command -v shodan >/dev/null 2>&1; then
        echo "Shodan CLI not found. Installing..."
        sudo apt-get update
        sudo apt-get install -y python3-pip
        pip3 install --upgrade shodan
        echo "Shodan CLI installed. Please re-run the script."
        exit 1
    fi
}

# Function to check and initialize the Shodan API key
check_api_key() {
    if ! shodan info >/dev/null 2>&1; then
        echo "No API key found. Please provide your Shodan API key:"
        read -r api_key
        shodan init "$api_key"
        echo "API key initialized."
    fi
}

# Check network connectivity to Shodan
check_network_comms() {
    if ! wget --tries=2 --timeout=8 -q --spider https://shodan.io; then
        echo "Cannot reach Shodan. Check your network or Shodan.io availability."
        exit 1
    fi
}

# Validate script inputs
check_inputs() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 [output filename] [country file] [vendor file]"
        echo "Example: $0 shodan-collection countries.txt vendors.txt"
        exit 1
    fi
}

# Print usage instructions
print_usage() {
    echo "Usage: $0 [output filename] [country file] [vendor file]"
    echo ""
    echo "This script uses the Shodan CLI to perform automated queries."
    echo "Ensure Shodan CLI is installed and API key is initialized."
    echo "Example: $0 shodan-collection countries.txt vendors.txt"
    echo ""
}

# Main script logic
main() {
    check_network_comms
    check_shodan
    check_api_key
    print_usage
    check_inputs "$@"

    output_file="$1"
    country_file="$2"
    vendor_file="$3"

    while IFS= read -r country; do
        while IFS= read -r vendor; do
            query_file="${output_file}.${country}.${vendor}"
            query_file=$(echo "$query_file" | tr -d '"' | tr -d "[:space:]" | sed 's/:/_/g')
            shodan download "$query_file" "$country" "$vendor" --limit 10000
        done < "$vendor_file"
    done < "$country_file"
}

# Execute the script
main "$@"
