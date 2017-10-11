require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'

configure do
  set :bind, '0.0.0.0'
end


if (defined?(ENV["VAULT_ADDR"]))
  vaultaddr = ENV["VAULT_ADDR"]
else
#Attempt to discover it through Consul
  consul = Resolv::DNS.new(:nameserver_port => [['127.0.0.1',8600]],
             :ndots => 1)
  vaulthost = consul.getaddress('vault.service.consul.').to_s
  vaultaddr = "https://#{vaulthost}:8200"
end
if (defined?(ENV["VAULT_TOKEN"]))
  vaulttoken = ENV["VAULT_TOKEN"]
else
#No one gave me a token, I'll try to find one
  vaulttoken = File.read("/tmp/vault-token")

end
if (defined?(ENV["VAULT_SKIP_VERIFY"]))
  ssl_verify = false
else
  ssl_verify = true
end

vault = Vault::Client.new(address: vaultaddr, token: vaulttoken.gsub("\n", ''), ssl_verify: false)
secret = vault.logical.read("secret/hello")

get '/' do
  erb :default, :locals => {:secret => secret.data[:key], :vault => vaultaddr}
end

get '/secret/:id' do
  secretpath = params[:id]
  secret = localvault.logical.read("secret/#{secretpath}")
  erb :default, :locals => {:secret => secret.data[:key], :vault => vaultaddr}
end


get '/test' do
  "Yeah, I'm up"
end
