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
  vaulttoken = File.read '/etc/vaulttoken'
  Vault.configure do |config|
    config.address = "https://"+ vaultaddr +":8200"
    config.token = vaulttoken
    config.ssl_verify = false
  end

  "Service discovery:
  Memcache is running on #{memcacheaddr}
  MySQL is running on #{mysqladdr}
  Vault is running on #{vaultaddr}"

  #mysqlsecret = Vault.logical.read("mysql/creds/readonly")
end

get '/test/' do
  "Yeah, I'm up"
end
