
#please do -not- run this as data_miner if you do not know why this message is here.

require 'mysql2'
require 'net/ssh/gateway'

require 'net/ssh'
require_relative '../Lowki.rb'

HOST = 'c2.blockshopper.com'
USER = 'ghuestis'
PASS = File.open('/home/mamanbrigitte/derpderp.txt', 'r').readline.chomp

local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

file = File.open('ns_vs_loki_newtown2.tsv', 'w')
puts "checksum 1"
Net::SSH.start( HOST, USER, :password => PASS ) do |ssh|
		puts "checksum 2"
		derf = ssh.exec!("mysql -u data_reader -pdata_reader -h db04 newtown_ct_tagging -e \"select * from deeds order by rand() limit 500\"")
		puts "checksum 3"
		derf_parsed = Targetfile.new(derf)
		derf_parsed.get_headers
		file.print "RAW\tNS_VERSION\tLOKI_VERSION\n"
		
		derf_parsed.each do |line|
			puts line
			file.puts "#{line['grantor_big']}\t#{line['grantor_together']}\t#{local_client.query("select grantor_together from db04_newtown_ct_tagging_deeds where doc_number = '#{line['doc_number']}'").first['grantor_together']}"
		end
end

#gate = Net::SSH::Gateway.new(HOST, USER, :password => PASS) 
#puts gate.active?()
#gate.ssh(HOST, USER, :password => PASS) do |tunnel|
#	puts tunnel.exec!('ls')
#	tunnel.exec!('ssh -R 3306:localhost:3306 ghuestis@c2.blockshopper.com')
#	vars = tunnel.exec!('mysql -u data_reader -p -h c3 will_il_raw -e "select * from deeds limit 1"')
#	puts "end"
#end

