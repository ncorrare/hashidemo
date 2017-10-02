#!/bin/sh
vault auth -token-only -method=aws role=test header_value=vault.example.com > /tmp/vault-token
exec ruby /usr/src/app/app.rb
