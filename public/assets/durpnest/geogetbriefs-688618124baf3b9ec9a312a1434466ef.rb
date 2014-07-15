
$STORE_PATH = File.expand_path(__FILE__).sub(/\/geogetbriefs.rb\s*$/, '')

require 'highline/import'
require 'net/ssh'
#require 'net/http'
require 'rest_client'
require 'json'
require_relative '../Lowki.rb'

$access_key = 'ixvybsXx9xSM3WRjjxsm'



local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

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
				name = rawr['name'].sub(/\\+n\s*/, '').sub(/,.*/, '').sub(/^\s*ultimate/i, '').gsub(/(?<!^|\s)([A-Z])/, ' \1').sub(/\(.*\)/, '').sub(/^\s*/, '').sub(/\s*$/, '')
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

puts "well, we're past this anyway..."
offset = 0
score = 0
unique = Hash.new
total = ''
Net::SSH.start( 'c2.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
	total = ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select count(distinct site_id, headline) from briefs\"").sub(/.*\n(.*)\n/, '\1')
end
p total
while offset >= 0
	time = Time.now
	targetfile_cms = ''
	
	
	#declare vars
	organization_ids = ''
	community_id = ''
	type_id = ''
	headline = ''
	author = ''
	teaser = ''
	body = ''
	external_debug = ''
	external_source = ''
	published = ''
	published_at = ''
	#end var dec
	
	
	Net::SSH.start( 'c2.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
		targetfile_cms = Targetfile.new(ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select * from briefs group by site_id, headline limit 10000 offset #{offset}\""))
		#total = ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select * from briefs group by site_id, headline limit 1000 offset #{offset}\"")
	end
	puts "data has been gathered"
	targetfile_cms.get_headers
	p targetfile_cms.headers
	portion = targetfile_cms.count
	targetfile_cms.each do |unique|
		organization = ''
		puts "#{unique['id']}||#{unique['site_id']}||#{unique['headline']}||#{unique['lat'].to_f}||#{unique['lon'].to_f}" if unique['lat'].to_f.round(5) != 0.0
		if gelf.orglink[unique['lat'].to_f] != nil
			if gelf.orglink[unique['lat'].to_f][unique['lon'].to_f] != nil and unique['lat'].to_f != 0
				organization = gelf.orglink[unique['lat'].to_f][unique['lon'].to_f]
				p organization
				score += 1
			end
		end
		organization_ids = "#{organization}"
		
		if gelf.db05comms_by_name[gelf.db05comms_by_id[unique['site_id']]]
			community_id = gelf.db05comms_by_name[gelf.db05comms_by_id[unique['site_id']]]
		else
			community_id = ''
		end
		
		type_id = "#{unique['type_id']}"
		type_id = 'NULL' if type_id == ''
		puts unique['id']
		headline = "#{unique['headline']}"
		headline = 'NULL' if headline == ''
		author = "#{unique['author']}"
		author = author = 'NULL' if author == ''
		teaser = "#{unique['teaser']}"
		teaser = 'NULL' if teaser == ''
		body = "#{unique['body']}"
		body = 'NULL' if body == ''
		external_debug = "site_id=#{unique['site_id']};brief_id=#{unique['id']};lat=#{unique['lat']};lon=#{unique['lon']}"
		external_source = 'NULL'
		
		published_at = unique['published']
		published = 0
		published = 1 if published_at != nil
		
		hash = {:organization_ids => organization_ids,
						:community_id => community_id,
						:type_id => type_id,
						:headline => headline,
						:author => author,
						:teaser => teaser,
						:body => body,
						:external_debug => external_debug,
						:external_source => external_source,
						:published => published,
						:published_at => published_at }
		if hash[:organization_ids] == '' and hash[:community_id] == ''
			puts "wiff!"
		  next
		end
		p hash
		
		url = "https://pipeline-staging.locallabs.com/api/v1/stories?access_key=#{$access_key}"
		#begin
			#puts hash.to_json
			#response = RestClient.post(url, hash.to_json, :content_type => :json, :accept => :json)
			#p "respo: #{response}"
		#rescue
		#	puts "post failed!"
		#	next
		#end
		puts "post succeeded!"
	end
	
	if portion < 10000
		offset = -1
	else
		offset += 10000
	end
	puts Time.now - time
	puts "#{offset} \/ #{total} :: #{score}"
end


