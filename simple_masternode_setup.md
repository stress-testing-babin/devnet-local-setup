# Simple Masternode Setup

After the setup of a fullnode one can create a Masternode with important requirements. A masternode is only formed if there is a address with 1000 Dash provided. This is a mechanism to secure a network so that attackers cannot abuse the privileged status of such node.

Interesting for any problems. The IP address is associated with the masternodes metadata, hence if the IP changes one has to update the ProRegTx... The setup process is not suitable for testnet or mainnet because details can be different and security measurements should be taken into account.

## Pre-Setup

```sh
# start the dashd
dashd

# execute the mnsync method with next until the output occurs 
# > [Output]: sync updated to MASTERNODE_SYNC_FINISHED
dash-cli mnsync next

# sent to any address of the current wallet 1050 Dash
# dash-cli getwalletinfo to check if tx is confirmed
GENERAL_ADDRESS=$(dash-cli getnewaddress)
echo "Send to this address ${GENERAL_ADDRESS} the required money"

# => "Confirm the transaction through mining"
#########################################################################################
```

Another option then sending funds to a address of the masternode it is also possible to to mine the required funds locally. `dash-cli generate 104` should be enough to get the reward + confirm it. The confirmed funds are required otherwise they cannot be used for later steps.

## Collateral, Keys, Addresses

```sh
# create collateral address and send 1000 Dash
COLLATERAL_ADDRESS=$(dash-cli getnewaddress)
COLLATERAL_HASH=$(dash-cli sendtoaddress ${COLLATERAL_ADDRESS} 1000)

# => "Confirm the transaction through mining"
#########################################################################################
```

Don't forget to confirm transaction. In the following step json-Object being parsed with a program called `jq` to make it easier retrieving information and saving it to a shell variable. Of course feel free to substitute it.

```sh
# get the output of the tx
COLLATERAL_OUTPUT=$(dash-cli masternode outputs | jq .\"${COLLATERAL_HASH}\" | tr -d '"')

# generate bls keys
BLS_KEYS=$(dash-cli bls generate)

# this step requires jq (sudo apt install jq)
SECRET_KEY=$(echo ${BLS_KEYS} | jq ."secret" | tr -d '"')
PUBLIC_KEY=$(echo ${BLS_KEYS} | jq ."public" | tr -d '"')

# create address for ProTx 
OWNER_ADDRESS=$(dash-cli getnewaddress)
VOTING_ADDRESS=$(dash-cli getnewaddress)
PAYOUT_ADDRESS=$(dash-cli getnewaddress)
FEE_SOURCE_ADDRESS=$(dash-cli getnewaddress)

# set money to payout and fee source to cover tx fees
dash-cli sendtoaddress ${PAYOUT_ADDRESS} 10
dash-cli sendtoaddress ${FEE_SOURCE_ADDRESS} 10

# => "Confirm the transaction through mining"
#########################################################################################
```

Don't forget to confirm transaction. Just a quick reminder :)

## ProTx

```sh
# get the local ip address
# optional set IP_ADDRESS manually
IP_ADDRESS=$(echo $(hostname -I) | awk -F" " '{print $1}') && echo ${IP_ADDRESS}
PORT="19999"

## NOTE 1: collateral_output can be found under `dash-cli masternode outputs`
## NOTE 2: operator award can be 0 for a devnet; see docs for further details 
PROTX_REGISTER=$(dash-cli protx register_prepare \
    ${COLLATERAL_HASH}                           \
    ${COLLATERAL_OUTPUT}                         \
    ${IP_ADDRESS}:${PORT}                        \
    ${OWNER_ADDRESS}                             \
    ${PUBLIC_KEY}                                \
    ${VOTING_ADDRESS}                            \
    0                                            \
    ${PAYOUT_ADDRESS}                            \
    ${FEE_SOURCE_ADDRESS})
SIGNMESSAGE=$(echo ${PROTX_REGISTER} | jq .signMessage  | tr -d '"')
REGISTER_TX=$(echo ${PROTX_REGISTER} | jq .tx | tr -d '"')

# Sign the the message with the private key of your collateral_addr as follows:
SIGNATURE=$(dash-cli signmessage ${COLLATERAL_ADDRESS} ${SIGNMESSAGE})

# do the submission with the previous values
SUBMIT_HASH=$(dash-cli protx register_submit ${REGISTER_TX} ${SIGNATURE})

# => "Confirm the transaction through mining"
#########################################################################################
```

## Final Touches

Finally one went through the whole process of setting a masternode up. All the information one could potentially need later is saved currently in shell variables. Those variable should be saved in a file...

```sh
# dump all the information into a file
FILENAME="masternode.txt"
echo "general address: ${GENERAL_ADDRESS}"                                 >> ${FILENAME}
echo "----- collateral informatlion -------------------------------------" >> ${FILENAME}
echo "address: ${COLLATERAL_ADDRESS}"                                      >> ${FILENAME}
echo "   hash: ${COLLATERAL_HASH}"                                         >> ${FILENAME}
echo   "index: ${COLLATERAL_OUTPUT}"                                       >> ${FILENAME}
echo "----- bls key -----------------------------------------------------" >> ${FILENAME}
echo "private: ${SECRET_KEY}"                                              >> ${FILENAME}
echo " public: ${PUBLIC_KEY}"                                              >> ${FILENAME}
echo "----- address -----------------------------------------------------" >> ${FILENAME}
echo "     owner: ${OWNER_ADDRESS}"                                        >> ${FILENAME}
echo "    voting: ${VOTING_ADDRESS}"                                       >> ${FILENAME}
echo "    payout: ${PAYOUT_ADDRESS}"                                       >> ${FILENAME}
echo "fee_source: ${FEE_SOURCE_ADDRESS}"                                   >> ${FILENAME}
echo "----- proRegTx ----------------------------------------------------" >> ${FILENAME}
echo "signing_msg: ${SIGNMESSAGE}"                                         >> ${FILENAME}
echo "register_tx: ${REGISTER_TX}"                                         >> ${FILENAME}
echo "  signature: ${SIGNATURE}"                                           >> ${FILENAME}
echo "submit_hash: ${SUBMIT_HASH}"                                         >> ${FILENAME}
```
