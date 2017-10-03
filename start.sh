#!/bin/sh
if $(vault auth -token-only -method=aws role=test header_value=vault.example.com > /tmp/vault-token); then
  echo "Vault Token Obtained"
  cat /tmp/vault-token
else
  echo "Couldn't get Vault token"
fi
exec ruby /usr/src/app/app.rb
