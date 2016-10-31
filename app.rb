require 'sinatra'
require 'fileutils'
require 'tempfile'
require 'net/http'
require 'yaml'
require 'vault'
require 'resolv'


get '/' do
  'Service discovery:'
  consul = Resolv::DNS.new(:nameserver_port => [['localhost',8600]],
           :ndots => 1)
  memcacheaddr = consul.getaddress('blogs.memcached.service.consul.').to_s
  "Memcache is running on #{memcacheaddr}"
  mysqladdr = consul.getaddress('blogs.mysql.service.consul.').to_s
  "MySQL is running on #{mysqladdr}"
  vaultaddr = consul.getaddress('production.vault.service.consul.').to_s
  "Vault is running on #{vaultaddr}"
  vaulttoken = File.read '/etc/vaulttoken'
  Vault.configure do |config|
    config.address = "https://"+ vaultaddr +":8200"
    config.token = vaulttoken
    config.ssl_verify = false
  end

  #mysqlsecret = Vault.logical.read("mysql/creds/readonly")
end

get '/test/' do
  "Yeah, I'm up"
end
