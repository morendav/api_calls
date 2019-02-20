#######################################
### Vault Tap
#
#     Takes in a UID used to open a vault of secrets, gathers vault secrets for use in other activities
#
#     Required parameters:
#       -u      = user login used to open the vault of secrets
#
#     Dependencies:
#         - User opening vault must have the iagstadm ad group (non prod conguration)
#         - User must be present in LDAP to auth to vault
#
#######################################
###     Passed Parameters & Init Var
#######################################
### config source and logging set up
source "$(pwd)/config"
printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault operations run" >> $LOGFILE

### Argument Operations
# For Help Option use -help
while getopts ":h:u:p:" opt; do
  case ${opt} in
    h ) printf "\nusage: vaultTap -u [user id] -p [password]
      Auth Options:
        -u    User id or user login used to use with vault operations";
        exit 0
        ;;
    u ) svcUid=$OPTARG;;
   \? )
     echo "Invalid Option: -$OPTARG. Use Option -help for more information" 1>&2
     exit 1
     ;;
  esac
done


#######################################
###     Unlock credentials
#######################################
credential=$(openssl rsautl -inkey "$LLAVE" -decrypt < "$CRED_DIRECTORY" )


#######################################
###     Vault Token Generation
#######################################
# Static variables
vaultAuth_url='URL_GOES_HERE'
uidPwd='{"password":"'$credential'"}'
# Generate OAuth Token - capture response
response_vaultAuth=$(curl "$vaultAuth_url" -X POST --data $uidPwd)
# capture repsonse key words
status=$(echo $response_vaultAuth | jq -r '.errors[0]')
policies=$(echo $response_vaultAuth | jq -r '.auth.token_policies' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g')
token=$(echo $response_vaultAuth | jq -r '.auth.client_token')
# Catch on vault Auth Error
if [[ "$status" =~ "fail" ]]; then
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault token request unsuccessful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  API response: $status" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  User policy not set" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  User token not set" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Check config file and associated RSAKey" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Script exit on error." >> $LOGFILE
  exit
else
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault token request successful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault policies set to:   $policies" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Extracting vault credentials" >> $LOGFILE
fi


#######################################
###     Vault Credentials Extraction
#######################################
# Static variables
vault_url='URL_GOES_HERE'
vaultToken="X-Vault-Token: $token"
# Generate OAuth Token - capture response
vaultResponse=$(curl "$vault_url" -H "$vaultToken")
# capture repsonse key words
requestID=$(echo $vaultResponse | jq -r '.request_id')
svcAccount_pwd=$(echo $vaultResponse | jq -r '.data.password')
svcAccount_uid=$(echo $vaultResponse | jq -r '.data.username')
status=$(echo $vaultResponse | jq -r '.data.password' || echo "fail")

# Catch on vault Auth Error
if [[ "$status" = "fail" ]]; then
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault tap unsuccessful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Check user policy for vault unlock" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Script exit on error." >> $LOGFILE
  exit
else
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault tap successful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  SVC Account extracted" >> $LOGFILE
fi


#######################################
###     Pass parameters out
###     Print completion to log file
#######################################
export svcAccount_pwd
export svcAccount_uid

printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Vault operations complete" >> $LOGFILE
