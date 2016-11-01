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
vaultaddr = consul.getaddress('production.vault.service.consul.').to_s
vaulttokenfile = File.read '/etc/vaulttoken'
vaulttoken = vaulttokenfile.tr("\n","")
localvault = Vault::Client.new(address: "https://#{vaultaddr}:8200", token: vaulttoken, ssl_verify: false)
def getmysqlcreds
  mysqlsecret = localvault.logical.read("mysql/creds/readonly")
  return mysqlsecret
end

mysqlvars = getmysqlcreds()

get '/' do
  begin
    client = Mysql2::Client.new(:host => mysqladdr, :username => mysqlvars.data[:username], :password => mysqlvars.data[:password])
    mysqlstatus = client.query("SHOW STATUS")
  rescue
    puts "Asking for new credentials"
    mysqlvars = getmysqlcreds()
    client = Mysql2::Client.new(:host => mysqladdr, :username => mysqlvars.data[:username], :password => mysqlvars.data[:password])
    mysqlstatus = client.query("SHOW STATUS")
  end
  "Service discovery: <br />\n
  Memcache is running on #{memcacheaddr} <br />\n
  MySQL is running on #{mysqladdr} <br />\n 
  Vault is running on #{vaultaddr} <br />\n
  Credentials: <br />\n
  Username is #{mysqlvars.data[:username]} <br />
  Below you'll find some mysql data: <br />
  #{mysqlstatus}
  "

end

get '/test' do
  "Yeah, I'm up"
end
