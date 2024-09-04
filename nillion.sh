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
CURRENT_RPC_INDEX=0

show_banner() {
    echo -e "${MAGENTA}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║         Welcome to Nillion                ║"
    echo "║            Coded By Onixia                ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

run_docker() {
    sudo docker run -d --name nillion-container -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:latest accuse --rpc-endpoint "${RPC_ENDPOINTS[$CURRENT_RPC_INDEX]}" --block-start "$(curl -s ${RPC_ENDPOINTS[$CURRENT_RPC_INDEX]}abci_info | jq -r '.result.response.last_block_height')"
}

check_and_remove_container() {
    if sudo docker ps -a | grep -q nillion-container; then
        echo -e "${YELLOW}Stopping and removing existing nillion-container...${NC}"
        sudo docker stop nillion-container
        sudo docker rm nillion-container
        sleep 10
    fi
}

monitor_logs() {
    local error_count=0
    while true; do
        if ! sudo docker ps | grep -q nillion-container; then
            echo -e "${RED}Container not running. Restarting...${NC}"
            break
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
                CURRENT_RPC_INDEX=$((CURRENT_RPC_INDEX + 1))
                if [ $CURRENT_RPC_INDEX -ge ${#RPC_ENDPOINTS[@]} ]; then
                    CURRENT_RPC_INDEX=0
                fi
                break
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
    check_and_remove_container
    run_docker
    echo -e "${BLUE}Container started with RPC endpoint: ${RPC_ENDPOINTS[$CURRENT_RPC_INDEX]}. Monitoring logs...${NC}"
    sleep 10
    monitor_logs
    check_and_remove_container
done
