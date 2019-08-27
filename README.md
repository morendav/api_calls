# RAM 2

Makes various API calls, passes parameters between shell scripts.

## Getting Started

Required Directories:
* Logging is set to write to          ./logs/
* Remediation file(s) present in      ./remediation/removals_file.json
* Support scripts located in          ./bin/
* Application local secrets           ./bin/secrets/l

Required Files:
* Configuration file                 ./config
* RSA Key file                       ./bin/secrets/llave.bin
* Encrypted SVC Credentials          ./bin/secrets/secret.bin

*NOTE* The local secrets folder and its contents are not hosted in this repo (for obvious reasons). You will need to create this diretory, create an RSA key, and encrypt the service account secret upon each new deployment. Notes on this process below.


### Dependencies

These scripts use extensively the jq utility that is non-native to centos deployments. There is a gitHub page that outlines this utility and its use.

Checking if JQ is installed in current Linux environment:
```
  jq --version
```

### Creating Missing Components

*HOW TO CREATE RSA KEY, AND STORE SECRETS IN LOCAL SECRETS BIN FOLDER*

  1) Create the ./bin/secrets/ directory, ensure you are able to write to this location.
  2) Create a shared RSA key
  ```
    openssl genrsa -out ./bin/secrets/llave.bin
  ```

  3) Encrypt a secret, store it in secrets folder
  ```
    echo "SUPER_SECRET_PASSWORD" | openssl rsautl -inkey ./bin/secrets/llave.bin -encrypt > ./bin/secrets/secret.bin
  ```

### Installing

Take this entire directory and deploy to server in /apps/*
Necessary additional steps are required to export and deploy form the ETL tool unto the server location

Run the application by running the app shell script as follows

```
  ./ram2.sh
```

## Versioning
*V1.1*
* working model for remediation steps only
* included some logging functionality
* works for lower env stage -
