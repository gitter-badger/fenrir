
time = Time.now
require 'mysql2'
require 'highline/import'
require 'net/ssh'
require 'net/http'
require_relative 'Lowki.rb'

HOST = 'c2.blockshopper.com'
DEEPHOST = 'c13.blockshopper.com'
#print "USER => "
USER = ask("User: "){|q| q.echo = false}
PASS = ask("Password: "){|q| q.echo = false}

mysql_host = 'db05'
mysql_database = 'games'
mysql_table = 'briefs'

x=0
y=0

local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')
whole_set = ''
pipecommhash = Hash.new

Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|

		puts "mysql -udata_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select count(*) from #{mysql_table}\""
	  whole_set = ssh.exec!("mysql -u data_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select count(*) from #{mysql_table}\"").sub(/count\(\*\)\n/, '').chomp
end

Net::SSH.start( DEEPHOST, USER, :password => PASS ) do|ssh|
	pipecomms = Targetfile.new(ssh.exec!("mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e \"select id, name from communities\""))
	pipecomms.get_headers
	
	pipecomms.each do |rawr|
		unless rawr['name'] == nil
			pipecommhash[rawr['name']] = rawr['id']
		end
	end
end

y = 0

while x >= 0


	puts "#{whole_set}"
	comms = ''
	Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
		comms = Targetfile.new(ssh.exec!("mysql -u data_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select id, name from list_websites\""))
	end
	comms.get_headers
	commiehash = Hash.new
	comms.each do |rawr|
		unless rawr['name'] == nil
			commiehash[rawr['id']] = rawr['name'].sub(/^\\+n\s*/, '').sub(/,.*/, '').sub(/^\s*/, '').sub(/\s*$/, '')
		end
	end
	derf = ''
	Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
		derf = Targetfile.new(ssh.exec!("mysql -u data_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select * from #{mysql_table} limit 10000 offset #{x}\""))
	end
	derf.get_headers

	
	unique = Hash.new
	
	derf.each do |d|
		next if unique[d] == 1
		unique[d] = 1
		id = d['site_id']
		comm_name = commiehash[d['site_id']].sub(/.*-(.*)$/, '\1').gsub(/^ultimate/i, '').gsub(/(?<!\s|^)([A-Z])/, ' \1').sub(/^\s*/, '').sub(/\s*$/, '')
		p "#{y} >>:#{id} => #{comm_name} => #{pipecommhash[comm_name]}"
		
		
		y += 1
	end
	
	x +=10000
	x = -1 if 10000 > derf.count
	
end

