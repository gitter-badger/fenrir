require 'mysql2'
require 'highline/import'
require 'net/ssh'

HOST = 'c2.blockshopper.com'
DEEPHOST = 'c13.blockshopper.com'
#print "USER => "
USER = ask("User: "){|q| q.echo = false}
PASS = ask("Password: "){|q| q.echo = false}

county_prefix = ''
configuration = ''
arguments = Hash.new
field_assignments = Hash.new
export_arguments = ''
cluster = 0

puts "county prefix:"
county_prefix = gets.chomp

puts "configuration name:"
configuration = gets.chomp
target = ''
source = ''
output_check = ''

until target[/[^\.]+\.[^\.]+\.[^\.]+/]
puts "target host.db.table:"
target = gets.chomp
end
until source[/[^\.]+\.[^\.]+\.[^\.]+/]
puts "source host.db.table:"
source = gets.chomp
end
puts "unique link (source > target):"
unique_key = gets.chomp
client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
client.query('use bedrock')

def check_prefix(county_prefix)
	Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
		tf = ssh.exec!("mysql -udata_miner -pdata_miner -h c13 core -e \"select tagging_db from markets where county_prefix = '#{county_prefix}'\"")
		return true if tf != nil
		return false if tf == nil
	end
end

def methodize(string)
	if w =~ /^\:/ and w =~ /\./
		w = Object.const_get("#{w.sub(/^\:(.*)\.[^,]+/, '\1')}")::method("#{w.sub(/^\:.*\.([^,]+)/, '\1')}")
	elsif w =~ /^\:\$/
		w = $global.local_variable_get(:"#{w.sub(/\:\$/, '')}")
	elsif w =~ /^\:/
		w = method(:"#{w.sub(/\:/, '')}")
	elsif w =~ /^\d{1,}$/
		w = w.to_i
	end
	
	return w
end



	target_host = target.sub(/([^\.]+)\..*/, '\1')
	target_db = target.sub(/[^\.]+\.([^\.]+)\..*/, '\1')
	target_table = target.sub(/[^\.]+\.[^\.]+\.([^\.]+)/, '\1')
	
	source_host = source.sub(/([^\.]+)\..*/, '\1')
	source_db = source.sub(/[^\.]+\.([^\.]+)\..*/, '\1')
	source_table = source.sub(/[^\.]+\.[^\.]+\.([^\.]+)/, '\1')
	
	arguments['local'] = "source_table=#{source_host}_#{source_db}_#{source_table} target_table=#{target_host}_#{target_db}_#{target_table}"
	if check_prefix(county_prefix)
		arguments['c13'] = "source_table=#{source_table} target_table=#{target_table}"
	else
		arguments['c13'] = "source_host=#{source_host} target_host=#{target_host} source_db=#{source_db} target_db=#{target_db} source_table=#{source_table} target_table=#{target_table}"
	end

puts "target fields (comma separate):"
targets = gets.chomp.split(/,/)

targets.each do |t|
  puts "past first"
	puts "constructor method for #{t}:"
	method = gets.chomp.strip
	
	#first check to see if county prefix has rules already
	
	puts "source field for #{t}:"
	source = gets.chomp
	
		target_field = t.chomp
		source_field = source.chomp
	#puts "arguments for constructor method (blank for string):"
	field_assignments[target_field] = "{#{source_field}=>#{method}}"
	output_check = output_check + ' ' + "r.#{source_field}, s.#{target_field},"
end

output_check = output_check.sub(/^\s*/, '').gsub(/\s{2,}/, ' ').sub(/,\s*$/, '')
field_assignments['unique_key'] = "#{unique_key}"

field_out = ''
field_assignments.each do |key, value|
	field_out=field_out+"#{key}=>#{value}"+','
end
field_out.sub!(/,\s*$/, '')

puts "LOCAL:\n"
puts "..........................."
local_command = "insert into procedures(county_prefix,configuration,arguments,field_assignments,export_arguments,cluster) values('#{county_prefix}','#{configuration}','#{arguments['local']}',\"args{#{field_out}}\",\"\",0);"
puts local_command
puts "...........................\n\n"
local_mysql_check = "select #{output_check} from #{source_host}_#{source_db}_#{source_table} r join #{target_host}_#{target_db}_#{target_table} s where r.#{unique_key.sub(/\>.*/, '')}=s.#{unique_key.sub(/.*\>/, '')} order by rand() limit 10"
puts local_mysql_check
p "does that look correct? (abort if no, 's' to skip local)"
confirmation = gets.chomp

unless confirmation == 's'
	client.query('use bedrock')
	client.query(local_command)
end

`ruby /home/mamanbrigitte/gitstore/Loki/procedures/Loki.rb :#{county_prefix}@#{configuration} local -t`

far_command = "insert into Loki_procedures(county_prefix,configuration,arguments,field_assignments,export_arguments,cluster) values('#{county_prefix}','#{configuration}','#{arguments['c13']}',\"args{#{field_out}}\",\"\",0);"
far_mysql_check = "select #{output_check} from #{source_db}.#{source_table} r join #{target_db}.#{target_table} s where r.#{unique_key.sub(/\>.*/, '')}=s.#{unique_key.sub(/.*\>/, '')} order by rand() limit 10"
puts far_command
puts "............................\n"
puts far_mysql_check
