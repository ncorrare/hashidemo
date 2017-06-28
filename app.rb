require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'

consul = Resolv::DNS.new(:nameserver_port => [['localhost',8600]],
           :ndots => 1)
vaultaddr = consul.getaddress('vault.service.consul.').to_s
vaulttoken = ENV["VAULT_TOKEN"]
vault = Vault::Client.new(address: "https://#{vaultaddr}:8200", token: vaulttoken, ssl_verify: false)
secret = localvault.logical.read("secret/hello")

get '/' do
  begin
    client = Mysql2::Client.new(:host => mysqladdr, :username => mysqlvars.data[:username], :password => mysqlvars.data[:password])
    mysqlstatus = client.query("SHOW STATUS")
  rescue
    puts "Asking for new credentials"
    mysqlvars = getmysqlcreds(localvault)
    client = Mysql2::Client.new(:host => mysqladdr, :username => mysqlvars.data[:username], :password => mysqlvars.data[:password])
    mysqlstatus = client.query("SHOW STATUS")
  end
  erb :default, :locals => {:secret => secret.data[:key], :vault => vaultaddr}

end

get '/test' do
  "Yeah, I'm up"
end
