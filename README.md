
### Nillion Docker Management Script

This script automates the process of managing a Docker container for the Nillion network. It handles container creation, monitoring, error detection, and automatic failover to alternative RPC endpoints in case of repeated errors. Below is a summary of what the script does:

#### Key Features:
• **Container Initialization**:
  - The script begins by checking if a container named `nillion-container` is already running. If it is, the script stops and removes it.
  - It then starts a new container using the `nillion/retailtoken-accuser` Docker image, connecting it to a specified RPC endpoint.

• **RPC Endpoint Management**:
  - The script allows for multiple RPC endpoints to be defined.
  - If errors are detected in the logs, the script will attempt to restart the container using the next available RPC endpoint after two errors. This process continues until all endpoints are exhausted, then it cycles back to the first.

• **Error Monitoring**:
  - The script continuously monitors the logs of the running container, specifically looking for errors.
  - If errors are found, the script tracks the count. After two consecutive errors, it stops the container, switches to the next RPC endpoint, and restarts the container.

• **Log Output**:
  - The script periodically outputs the current status, including any registered nodes, found secret stores, and challenges sent to Nilchain.
  - This information helps monitor the health and activity of the container.

• **Automatic Restarts**:
  - If the container stops running for any reason, the script will automatically attempt to restart it.

#### Key Changes:
• **Removing Stopped Containers**: The script now removes not only running containers but also any stopped containers with the same name.
• **Improved Container Management**: By removing stopped containers, the script prevents the creation of redundant containers.

These updates should address your issue and ensure that only one container is active at a time.


## Prerequisites:
1. Nillion Address: Install Keplr and create a Nillion address if you don't have one.
2. Add Nillion Testnet: Open Keplr, search for "Nillion," click "Manage Chain," and add the Nillion Testnet.
https://verifier.nillion.com/
# Setup Instructions

## Update system and install Docker
```bash
sudo apt update && sudo apt install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## Pull Nillion Accuser image
```bash
sudo docker pull nillion/retailtoken-accuser:latest
```

## Create directory and initialize Accuser
```bash
mkdir -p ~/nillion/accuser
sudo docker run -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:latest initialise
```

## Retrieve account_id and public_key
```bash
cat ~/nillion/accuser/credentials.json
```

>> Visit the faucet site to request tokens. Use the `account_id` and `public_key` from the previous step.



## Install jq
```bash
sudo apt update && sudo apt install -y jq
```

## Final Steps
This script continuously checks the logs and restarts the node if any errors are found.

![image](https://github.com/user-attachments/assets/3b8654ec-b674-49ad-8811-e4ef2255d3e3)




```bash
screen -S nillion
```
```bash
cd ~ && rm nillion.sh
wget https://raw.githubusercontent.com/Onixs50/nillion-fixed/main/nillion.sh
chmod +x nillion.sh
./nillion.sh
```
