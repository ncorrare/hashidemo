require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'

consul = Resolv::DNS.new(:nameserver_port => [['172.17.0.1',8600]],
           :ndots => 1)
vaultaddr = consul.getaddress('vault.service.consul.').to_s
vaulttoken = ENV["VAULT_TOKEN"]
vault = Vault::Client.new(address: "https://#{vaultaddr}:8200", token: vaulttoken, ssl_verify: false)
secret = localvault.logical.read("secret/hello")

get '/' do
  erb :default, :locals => {:secret => secret.data[:key], :vault => vaultaddr}

end

get '/test' do
  "Yeah, I'm up"
end
