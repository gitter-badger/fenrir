
require 'mysql2'
#~ require 'net/ssh/gateway'
require 'highline/import'

require 'net/ssh'
require_relative '../Lowki.rb'

HOST = 'c2.blockshopper.com'
#print "USER => "
USER = ask("User: "){|q| q.echo = false}
PASS = ask("Password: "){|q| q.echo = false}

mysql_host = 'db04'
mysql_database = 'butler_oh_raw'
mysql_table = 'hyperlocal_sheriff_incidents'


local_client = Mysql2::Client.new(:host =>'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

Net::SSH.start( HOST, USER, :password => PASS ) do |ssh|
	puts "inside ssh tunnel"
	puts ssh.exec!('ruby -v')
	#derf = far_client.query('mysql -u data_reader -pdata_reader -h c3 will_il_raw -e "select * from deeds limit 100"')
		rules = ssh.exec!("mysql -udata_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"show create table #{mysql_table}\"").gsub(/\\n|\n/, '').sub(/.*create table `#{mysql_table}`/i, "CREATE TABLE IF NOT EXISTS `#{mysql_host}_#{mysql_database}_#{mysql_table}`")
    puts rules
    local_client.query("#{rules.sub(/AUTO_INCREMENT=[\d+]\b/, 'AUTO_INCREMENT=0')}")
  
  
  
	x=0
	y=0
	$headers = ''
	$updates = ''
	while x >= 0
		puts "loopstart"
    whole_set = ssh.exec!("mysql -u data_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select count(*) from #{mysql_table}\"").sub(/count\(\*\)\n/, '').chomp
		derf = ssh.exec!("mysql -u data_miner -pdata_miner -h #{mysql_host} #{mysql_database} -e \"select * from #{mysql_table} order by date desc limit 10000 offset #{x}\"")
		derf_parsed = Targetfile.new(derf)
		derf_parsed.get_headers
    section = derf_parsed.count
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
			local_client.query("insert into #{mysql_host}_#{mysql_database}_#{mysql_table}(#{$headers}) values(#{values}) on duplicate key update #{$updates}")
      y+=1
      puts "#{whole_set}: #{x} / #{section} / #{y}"
		end
		puts "data processed"
		x+=10000
    y=0
		
		x = -1 if 10000 > derf_parsed.count
	end
end
