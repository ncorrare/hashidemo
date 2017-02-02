require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'

consul = Resolv::DNS.new(:nameserver_port => [['localhost',8600]],
           :ndots => 1)
memcacheaddr = consul.getaddress('blogs.memcached.service.consul.').to_s
mysqladdr = consul.getaddress('blogs.mysql.service.consul.').to_s
vaultaddr = consul.getaddress('vault.service.consul.').to_s
vaulttokenfile = File.read '/etc/vaulttoken'
vaulttoken = vaulttokenfile.tr("\n","")
localvault = Vault::Client.new(address: "https://#{vaultaddr}:8200", token: vaulttoken, ssl_verify: false)
mysqlsecret = localvault.logical.read("mysql/creds/readonly")


get '/' do
  "Service discovery: <br />\n
  Memcache is running on #{memcacheaddr} <br />\n
  MySQL is running on #{mysqladdr} <br />\n 
  Vault is running on #{vaultaddr} <br />\n
  Credentials: <br />\n
  Username is #{mysqlsecret.data[:username]}
  "

end

get '/test' do
  "Yeah, I'm up"
end
