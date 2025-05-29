#!/bin/zsh

# Script to analyze OpenShift cluster resource usage across namespaces
# This script requires 'oc' CLI to be installed and user to be logged in

# Enable better error handling
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting OpenShift Cluster Resource Analysis...${NC}\n"

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check if oc is installed and user is logged in
check_oc() {
    if (( ! $+commands[oc] )); then
        echo -e "${RED}Error: oc command not found. Please install the OpenShift CLI.${NC}"
        exit 1
    fi

    if ! oc whoami &> /dev/null; then
        echo -e "${RED}Error: Not logged into OpenShift. Please run 'oc login' first.${NC}"
        exit 1
    fi
}

# Function to get resource usage for a namespace
get_namespace_usage() {
    local namespace=$1
    echo -e "\n${GREEN}Namespace: ${namespace}${NC}"
    
    # Get CPU and Memory requests/limits
    echo "Resource Quotas:"
    oc get resourcequota -n $namespace -o custom-columns=NAME:.metadata.name,CPU_REQUEST:.spec.hard.requests.cpu,CPU_LIMIT:.spec.hard.limits.cpu,MEMORY_REQUEST:.spec.hard.requests.memory,MEMORY_LIMIT:.spec.hard.limits.memory 2>/dev/null || echo "No resource quotas found"
    
    # Get current CPU and Memory usage
    echo -e "\nCurrent Resource Usage:"
    oc get pods -n $namespace -o custom-columns=NAME:.metadata.name,CPU_REQUEST:.spec.containers[*].resources.requests.cpu,CPU_LIMIT:.spec.containers[*].resources.limits.cpu,MEMORY_REQUEST:.spec.containers[*].resources.requests.memory,MEMORY_LIMIT:.spec.containers[*].resources.limits.memory 2>/dev/null || echo "No pods found"
    
    # Get actual resource consumption
    echo -e "\nActual Resource Consumption:"
    oc adm top pods -n $namespace 2>/dev/null || echo "Unable to get resource consumption data"
}

# Main script execution
check_oc

print_header "Cluster Information"
echo "OpenShift Version: $(oc version | grep Server | awk '{print $2}')"
echo "Current User: $(oc whoami)"
echo "Current Project: $(oc project -q)"

print_header "Resource Usage by Namespace"
# Get all namespaces
namespaces=($(oc get namespaces -o jsonpath='{.items[*].metadata.name}'))

# Process each namespace
for ns in $namespaces; do
    get_namespace_usage $ns
done

print_header "Summary"
echo "Total Namespaces: ${#namespaces}"
echo -e "\n${GREEN}Analysis complete. Review the output above for resource usage details.${NC}"
echo -e "${YELLOW}Note: Some metrics might not be available if you don't have sufficient permissions.${NC}" 