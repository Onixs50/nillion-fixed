#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define RPC endpoints
RPC_ENDPOINTS=("https://testnet-nillion-rpc.lavenderfive.com/" "https://nillion-testnet-rpc.polkachu.com" "https://nillion-testnet.rpc.kjnodes.com")

show_banner() {
    echo -e "${MAGENTA}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║         Welcome to Nillion                ║"
    echo "║            Coded By Onixia                ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

get_random_rpc() {
    echo "${RPC_ENDPOINTS[$RANDOM % ${#RPC_ENDPOINTS[@]}]}"
}

run_docker() {
    local rpc_endpoint="$1"
    sudo docker run -d --name nillion-container -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.1 accuse --rpc-endpoint "$rpc_endpoint" --block-start "$(curl -s ${rpc_endpoint}abci_info | jq -r '.result.response.last_block_height')"
}

check_and_remove_containers() {
    echo -e "${YELLOW}Stopping all nillion containers...${NC}"
    sudo docker stop $(sudo docker ps -a -q --filter name=nillion-container) 2>/dev/null
    echo -e "${YELLOW}Waiting 30 seconds after stopping containers...${NC}"
    sleep 30

    echo -e "${YELLOW}Removing all nillion containers...${NC}"
    sudo docker rm $(sudo docker ps -a -q --filter name=nillion-container) 2>/dev/null
    echo -e "${YELLOW}Waiting 30 seconds after removing containers...${NC}"
    sleep 30
}

monitor_logs() {
    local error_count=0
    while true; do
        if ! sudo docker ps | grep -q nillion-container; then
            echo -e "${RED}Container not running. Restarting...${NC}"
            return 1
        fi
        logs=$(sudo docker logs --tail 50 nillion-container 2>&1)
        
        echo -e "${CYAN}Current status:${NC}"
        registered=$(echo "$logs" | grep "Registered:" | tail -n 1)
        secret_stores=$(echo "$logs" | grep "Secret stores Found:" | tail -n 1)
        challenges=$(echo "$logs" | grep "Challenges sent to Nilchain" | tail -n 1)
        echo -e "${GREEN}$registered${NC}"
        echo -e "${GREEN}$secret_stores${NC}"
        echo -e "${GREEN}$challenges${NC}"
        
        if echo "$logs" | grep -q "Error"; then
            error_count=$((error_count + 1))
            echo -e "${RED}Error detected in logs. Error count: $error_count / 2${NC}"
            if [ $error_count -ge 2 ]; then
                echo -e "${RED}Error threshold reached. Switching RPC endpoint and restarting container...${NC}"
                return 1
            fi
        else
            error_count=0
        fi
        sleep 60
    done
}

clear
show_banner

while true; do
    check_and_remove_containers
    rpc_endpoint=$(get_random_rpc)
    echo -e "${BLUE}Using RPC endpoint: $rpc_endpoint${NC}"
    run_docker "$rpc_endpoint"
    echo -e "${BLUE}Container started. Waiting 30 seconds before monitoring logs...${NC}"
    sleep 30
    if ! monitor_logs; then
        echo -e "${YELLOW}Restarting process with a new RPC endpoint...${NC}"
    fi
done
