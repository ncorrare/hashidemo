FROM ruby:2.1-onbuild
RUN "curl -o /tmp/vault.zip https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip"
RUN "unzip /tmp/vault.zip -d /bin"
ENTRYPOINT ["vault auth -token-only -method=aws role=test header_value=vault.example.com > /tmp/vault-token"]
CMD ["./app.rb"]