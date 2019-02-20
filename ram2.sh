#######################################
### Rogue Access Management 2 App Thread
#
#     Threaded Rogue Access Managment applicaiton model.
#     Single bash shell script intended to thread all RAM components together.
#         1. RAM Detection
#         2. RAM Remediation
#
#     Dependencies:
#         - All sub-utilities have dependencies listed in their shell scripts
#         - All support scripts make use of JQ to parse json, check version in deployment env by running jq --version
#
#######################################
###     Init Variables and Config File
#######################################
source "$(pwd)/config"
printf "`date "+%Y-%m-%d %H:%M:%S"`  RAM2.0 application start" > $LOGFILE

#######################################
###     Threaded Remediaiton Steps
#######################################
# open the vault, gather bulk removal credentials
. $AncillaryBin/vaultTap.sh -u "$ROGUESVC"
# generate bulk removals using bulk request API
$AncillaryBin/bulkRequests.sh -p "$svcAccount_pwd" -u "$svcAccount_uid"
# report to log application complete
printf "\n`date "+%Y-%m-%d %H:%M:%S"`  RAM2.0 application completed" >> $LOGFILE
