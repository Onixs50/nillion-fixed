# nillion-fixed



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



>> After 5 errors, the node is continuously rebooted

```bash
screen -S nillion
wget https://raw.githubusercontent.com/Onixs50/nillion-fixed/main/nillion.sh
chmod +x nillion.sh
./nillion.sh
```
