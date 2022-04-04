#!/bin/bash

# Configure service principals, author AKV secrets containing their credentials, then
# create an access policy for them to retrieve secrets from the very same AKV.
# This is required in order to allow the CSI driver to mount secrets.
# The ACI team has not yet implemented managed identities for AKS.
# If using CloudShell, do az login first on old builds or use AZCLI
#Might get HTTPS errors in JB, use SAW version for connection

VAULT_NAME="${VAULT_NAME:-dlgaas-usme1-vault}"

echo "===== [[ Using VAULT_NAME: ${VAULT_NAME} ]] ====="

for state in va tx; do
    spName="nuance-coretech-dlgaas-usme1${state}us-akvreader"
    spOutputFile="${state}-service-principal-output-SENSITIVE.txt"
    secretName="usme1${state}us-dlgaas-base-helm-values-secret-overrides"
    secretOutputFile="${state}-secret-output-SENSITIVE.txt"

    echo "===== [[ ${state} Creating Service Principal: ${spName} ]] ====="
    az ad sp create-for-rbac --name "${spName}" --scopes "" --output table --years 2 > "${spOutputFile}"

    echo "===== [[ ${state} Creating Secret: ${secretName} ]] ====="
    secretValue="$(head -n3 < "${spOutputFile}" | tail -n1 | awk '{print "keyvault.spid="$1";keyvault.spsecret="$3}')"
    az keyvault secret set --name "${secretName}" --value "${secretValue}" --vault-name "${VAULT_NAME}" > "${secretOutputFile}"
   
    spAppId="$(head -n3 < "${spOutputFile}" | tail -n1 | awk '{print $1}')"
    echo "===== [[ ${state} Creating Access Policy for: ${spName} / AppId: ${spAppId} ]] ====="
    az keyvault set-policy --name "${VAULT_NAME}"   \
        --secret-permissions get                    \
        --certificate-permissions get getissuers    \
        --spn "${spAppId}"
done

echo "===== [[ Creating Access Policy for Ev2 (Composite Identity) ]] ====="
az keyvault set-policy --name "${VAULT_NAME}" --application-id 5744bc69-8a73-45f7-958d-4640d865f04d --object-id 5669f94c-fbd0-45f5-ab04-ffb0c5cef6f4
