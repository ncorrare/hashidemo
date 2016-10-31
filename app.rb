require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'


get '/' do
  consul = Resolv::DNS.new(:nameserver_port => [['localhost',8600]],
           :ndots => 1)
  memcacheaddr = consul.getaddress('blogs.memcached.service.consul.').to_s
  mysqladdr = consul.getaddress('blogs.mysql.service.consul.').to_s
  vaultaddr = consul.getaddress('production.vault.service.consul.').to_s
  vaulttokenfile = File.read '/etc/vaulttoken'
  vaulttoken = vaulttokenfile.tr("\n","")
  localvault = Vault::Client.new(address: "https://#{vaultaddr}:8200", token: vaulttoken, ssl_verify: false)
  mysqlsecret = localvault.logical.read("mysql/creds/readonly")

  "Service discovery:
  Memcache is running on #{memcacheaddr}
  MySQL is running on #{mysqladdr}, Username is #{mysqlsecret.data[:username]}
  Vault is running on #{vaultaddr}"

end

get '/test' do
  "Yeah, I'm up"
end
