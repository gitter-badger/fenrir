$STORE_PATH = File.expand_path(__FILE__).sub(/\/geoput2.rb\s*$/, '')

require 'highline/import'
require 'net/ssh'
#require 'net/http'
require 'rest_client'
require 'json'
require_relative '../Lowki.rb'

$access_key = 'ixvybsXx9xSM3WRjjxsm'

class Structure
	attr_accessor :c13comms_by_name, :c13comms_by_id, :db05comms_by_name, :db05comms_by_id, :orglink
	def initialize
		time = Time.now
		@c13comms_by_name = Hash.new
		@c13comms_by_id = Hash.new
		@db05comms_by_name = Hash.new
		@db05comms_by_id = Hash.new
		@orglink = Hash.new
		Net::SSH.start( 'c13.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
			c13comms_ssh = Targetfile.new(ssh.exec!("mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e \"select id, name from communities\""))
			c13comms_ssh.get_headers
			c13comms_ssh.each do |rawr|
				@c13comms_by_name[rawr['name']] = rawr['id']
				@c13comms_by_id[rawr['id']] = rawr['name']
			end
		end
		Net::SSH.start( 'c2.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
			db05comms_ssh = Targetfile.new(ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select id, name from list_websites\""))
			db05comms_ssh.get_headers
			db05comms_ssh.each do |rawr|
			  #p rawr
				if rawr['name'] == nil
					rawr['name'] = ''
				end
				name = rawr['name'].sub(/\\+n\s*/, '').sub(/^\s*ultimate/i, '').gsub(/(?<!^|\s)([A-Z])(?=[a-z])/, ' \1').sub(/\(.*\)/, '').sub(/^\s*/, '').sub(/\s*$/, '')
				id = rawr['id']
				@db05comms_by_name[name] = id
				@db05comms_by_id[id] = name
			end
			Dir.chdir($STORE_PATH)
			if File.exists?("./cleanhash.txt")
				puts "hash file exists.  Bypassing loading procedure."
				File.open("cleanhash.txt", 'r') do |file|
					file.each do |line|
						@orglink[line.chomp.sub(/([^\t]+)\t.*/, '\1').to_f] = { line.chomp.sub(/[^\t]+\t([^\t]+)\t.*/, '\1').to_f => line.chomp.sub(/[^\t]+\t[^\t]+\t(.*)/, '\1') } 
					end
				end
			else
				File.open("cleanhash.txt", 'w') do |saveit|
					orglink_ssh = Targetfile.new(ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select s.story_id, s.organization_id, o.lat, o.lon from stories_organizations s join organizations o where s.organization_id = o.id\""))
					orglink_ssh.get_headers
					orglink_ssh.each do |rawr|
						#p rawr
						valid = 1
						@orglink[rawr['story_id']] = rawr['organization_id']
						if !@orglink[rawr['lat'].to_f]
							begin
								valid = RestClient.get("https://pipeline-staging.locallabs.com/api/v1/organizations/#{rawr['organization_id']}?access_key=#{$access_key}")
							rescue
								valid = 0
							end
							puts "invalid" if valid == 0
							@orglink[rawr['lat'].to_f] = {rawr['lon'].to_f => rawr['organization_id']} unless valid == 0
							saveit.puts "#{rawr['lat'].to_f}\t#{rawr['lon'].to_f}\t#{rawr['organization_id']}" unless valid == 0
						else
							if !@orglink[rawr['lat'].to_f][rawr['lon'].to_f]
								begin
									valid = RestClient.get("https://pipeline-staging.locallabs.com/api/v1/organizations/#{rawr['organization_id']}?access_key=#{$access_key}")
								rescue
									valid = 0
								end
								puts "invalid" if valid == 0
								@orglink[rawr['lat'].to_f][rawr['lon'].to_f] = rawr['organization_id'] unless valid == 0
								saveit.puts "#{rawr['lat'].to_f}\t#{rawr['lon'].to_f}\t#{rawr['organization_id']}" unless valid == 0
							else
								if rawr['organization_id'] = @orglink[rawr['lat'].to_f][rawr['lon'].to_f]
								else
									puts "conflict in orgs"
									wait = gets
								end
							end
						end
					end
				end	
				#p @orglink
			end
		end
		puts Time.now - time
	end
end

gelf = Structure.new

File.open('db05comms.txt', 'w') do |file|
File.open('c13comms.txt', 'w') do |file2|
	arraydb05 = Array.new
	arrayc13 = Array.new
	gelf.db05comms_by_id.each do |key, value|
		#if gelf.c13comms_by_name[value]
		#	puts "found in c13: #{gelf.c13comms_by_name[value]}, #{value}"
		#else
			arraydb05 << value
		#end
	end
	
	gelf.c13comms_by_id.each do |key, value|
		arrayc13 << value
	end
	arraydb05.sort.each do |item|
		file.puts item
	end
	arrayc13.sort.each do |item|
	  file2.puts item
	end

end
end
