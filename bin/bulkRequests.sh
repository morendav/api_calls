#######################################
### Bulk Request Generator
#
#     Takes in a passed credential and uses it to
#         + Create an OAuth token (expires in 1 hours)
#         + Use OAuth token to generate bulk requests from JSON input file
#
#     Required parameters:
#       -p      = Password for the account that will be used to generate the bulk requests
#       -u      = user login or user id used to generate oauth token
#
#     Dependencies:
#         - User generating the bulk requests must be present in IME and the IME group called "TGTNEXTGEN_DEVOPS"
#
#######################################
###     Passed Parameters & Init Var
#######################################
### config source and logging set up
source "$(pwd)/config"
printf "\n`date "+%Y-%m-%d %H:%M:%S"`  bulkRequestor.sh run" >> $LOGFILE

### Argument Operations
# For Help Option use -help
while getopts ":h:u:p:" opt; do
  case ${opt} in
    h ) printf "\nusage: ./bulkRequests.sh -u [user id] -p [password]
      Auth Options:
        -u    User id or user login used to retrieve OAuth token
        -p    User pwd for use in the OAuth step";
        exit 0
        ;;
    u ) uid=$OPTARG;;
    p ) pwd=$OPTARG;;
   \? )
     echo "Invalid Option: -$OPTARG. Use Option -help for more information" 1>&2
     exit 1
     ;;
  esac
done


#######################################
###     Generate OAuth Token
#######################################
# Static variables
oauth_url='URL_GOES_HERE'
oauth_header1='Content-Type: application/x-www-form-urlencoded'
oauth_header2='Accept: application/json'
oauth_uid="username=$uid&password=$pwd"
# Generate OAuth Token
response_oAuth=$(curl -X POST --header "$oauth_header1" --header "$oauth_header2" -d "$oauth_uid" "$oauth_url")
# capture repsonse key words
status=$(echo $response_oAuth | jq -r '.status')
token=$(echo $response_oAuth | jq -r '.encodedValue')
authStats=$(echo $response_oAuth | jq -r '.isAuthenticated')
# Catch on oAuth error
if [ $status != "Success" ]; then
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  OAuth unsuccessful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  API response: $status" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  User authentication status: $authStats" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Auth JSON Response: $response_oAuth" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Check config file and associated RSAKey, ensure positive match" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Script exit on error." >> $LOGFILE
  exit
else
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  OAuth attempt successful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  OAuth User ID: $uid." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Passing bulk request JSON to API" >> $LOGFILE
fi


#######################################
###     Bulk Removal Submission
#######################################
blkrqst_url='URL_GOES_HERE'
blkrqst_header1='Content-Type: application/json'
blkrqst_header2='Accept: application/json'
blkrqst_header3="Authorization: $token"
# Call bulk request API
response_blkrqst=$(curl -X POST --header "$blkrqst_header1" --header "$blkrqst_header2" --header "$blkrqst_header3" -d $(echo $REMOVALS_JSON) 'URL_GOES_HERE')
# capture repsonse key words
status=$(echo $response_blkrqst | jq -r '.status' || echo "fail")


# Catch on request API
if [ $status != "Success" ]; then
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Bulk request api call unsuccessful." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  API response: $status" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  API response:" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  $response_blkrqst" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Request API passed json at location: $REMOVALS_JSON" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Script exit on error." >> $LOGFILE
  exit
else
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Bulk request api status: $status." >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Bulk requests generated" >> $LOGFILE
  printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Bulk request API, request keys |$response_blkrqst" >> $LOGFILE
fi

printf "\n`date "+%Y-%m-%d %H:%M:%S"`  Bulk request submission complete" >> $LOGFILE
