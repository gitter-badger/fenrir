
require 'mysql2'
#~ require 'net/ssh/gateway'

require 'net/ssh'
require_relative '../Lowki.rb'
require 'highline/import'

HOST = 'c2.blockshopper.com'
USER = 'jputz'
puts "Password on key is needed."
PASS = ask("Password: "){|q| q.echo = false}


local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
	puts "inside ssh tunnel"
	puts ssh.exec!('ruby -v')
	#derf = far_client.query('mysql -u data_reader -pdata_reader -h c3 will_il_raw -e "select * from deeds limit 100"')
	
	x=0
	
	$headers = ''
	$updates = ''
	while x >= 0
		puts "loopstart"
		derf = ssh.exec!("mysql -u data_reader -pdata_reader -h c3 will_il_tagging -e \"select * from deeds limit 10000 offset #{x}\"")
		derf_parsed = Targetfile.new(derf)
		derf_parsed.get_headers
		headers = ''
		puts "data fetched"
		if $headers == '' and $updates == ''
			derf_parsed.headers.each do |header|
				header = header.gsub(/(\"|\'|\:|\#)/, '\\\\\1')
				$headers = $headers + ", #{header}"
				$updates = $updates + ", #{header} = VALUES\(#{header}\)"
			end
			$headers = $headers.sub(/^\s*,\s*/, '')
			$updates = $updates.sub(/^\s*,\s*/, '')
			p $headers
			p $updates
			wait = gets
		end
				
		derf_parsed.each do |line|
			values = ''
			line.each do |key, value|
				if value == nil
					value = ''
				end
				value = value.gsub(/(\"|\'|\:|\#)/, '\\\\\1')
				if value.match(/^\d+$/)
					values = values + ", #{value}"
				else
					values = values + ", '#{value}'"
				end
			end
			values = values.sub(/^\s*,\s*/, '')
			local_client.query("insert into c3_will_il_tagging_deeds(#{$headers}) values(#{values}) on duplicate key update #{$updates}")
		end
		puts "data processed"
		x+=10000
		puts x
		
		x = -1 if 10000 > derf_parsed.count
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

