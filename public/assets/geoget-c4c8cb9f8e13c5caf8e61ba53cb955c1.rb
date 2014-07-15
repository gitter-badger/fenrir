

require 'mysql2'
require 'highline/import'
require 'net/ssh'
require 'net/http'
require_relative 'Lowki.rb'

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
			  p rawr
				if rawr['name'] == nil
					rawr['name'] = ''
				end
				name = rawr['name'].sub(/\\+n\s*/, '').sub(/,.*/, '').sub(/^\s*ultimate/i, '').gsub(/(?<!^|\s)([A-Z])/, ' \1').sub(/\(.*\)/, '').sub(/^\s*/, '').sub(/\s*$/, '')
				id = rawr['id']
				@db05comms_by_name[name] = id
				@db05comms_by_id[id] = name
			end
			orglink_ssh = Targetfile.new(ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select story_id, organization_id from stories_organizations\""))
			orglink_ssh.get_headers
			orglink_ssh.each do |rawr|
				@orglink[rawr['story_id']] = rawr['organization_id']
			end
		end
		puts Time.now - time
	end
end

gelf = Structure.new

offset = 0
orglinkz = 0

while offset >= 0
	targetfile_cms = ''
	Net::SSH.start( 'c2.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
		targetfile_cms = Targetfile.new(ssh.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select * from stories order by legacy_id asc limit 10000 offset #{offset}\""))
	end
	targetfile_cms.get_headers
	portion = targetfile_cms.count
	p targetfile_cms.headers
	
	unique = Hash.new
	targetfile_cms.each do |target|
		system('clear')
		headline = target['headline']
		legacy = target['legacy_id']
		p "legacy_id: #{legacy}"
		if !unique[legacy]
			unique[legacy] = Hash.new
		end
		if !unique[legacy][headline]
			unique[legacy][headline] = Hash.new
			unique[legacy][headline]['communities'] = Array.new
			unique[legacy][headline]['organizations'] = Array.new
		end
		unique[legacy][headline]['communities'] << target['site_id']
		#if unique[legacy][headline]['communities'].count > 1 and legacy.to_i > 270000
			#puts "site_ids associated: #{unique[legacy][headline]['communities'].to_s}"
			#wait = gets
		#else
			puts "site_ids associated: #{unique[legacy][headline]['communities'].to_s}"
		#end
		if gelf.orglink[legacy]
			unique[legacy][headline]['organizations'] << gelf.orglink[legacy].to_i
			puts "organization: #{gelf.orglink[legacy]}"
			orglinkz += 1
		else
			puts "organization link unsuccessful.  It probably would've fallen down anyway."
			unique[legacy][headline]['organizations'] << 9999999990 unless unique[legacy][headline]['organizations'].include?(9999999990)
		end
		unique[legacy][headline]['type_id'] = target['type_id']
		unique[legacy][headline]['headline'] = headline
		unique[legacy][headline]['author'] = target['author']
		unique[legacy][headline]['teaser'] = target['teaser']
		unique[legacy][headline]['body'] = target['body']
		unique[legacy][headline]['external_debug'] = 'NULL'
		unique[legacy][headline]['external_source'] = 'NULL'
		unique[legacy][headline]['published'] = target['published']
		unique[legacy][headline]['published_at'] = target['published_at']
		unique[legacy][headline]['exported'] = 0
		unique[legacy][headline]['legacy_id'] = legacy
		unique[legacy][headline]['site_id'] = target['site_id']

		puts orglinkz		

	end
	unique.each do |key, leg|
		leg.each do |key, head|
			
			site_id = head['site_id']
			legacy = head['legacy_id']
			headline = head['headline']
			community = gelf.c13comms_by_name[gelf.db05comms_by_id[site_id]]
			
			organization_ids = head['organizations'].to_s
			if community != '' and community != nil
				community_id = community.to_i
			else
				community_id = "9999999990#{site_id}".to_i
			end
			type_id = head['type_id']
			headline = head['headline']
			author = head['author']
			teaser = head['teaser']
			body = head['body']
			external_debug = 'NULL'
			external_source = 'NULL'
			published = head['published']
			published_at = head['published_at']
			exported = 0
			legacy_id = legacy
			puts "inserting #{legacy_id}"
			puts "x: #{x}"
			begin
				local_client.query("insert into pipeline_stories(organization_ids, community_id, type_id, headline, author, teaser, body, external_debug, external_source, published, published_at, exported, legacy_id) values('#{organization_ids}','#{community_id}','#{type_id}','#{headline}','#{author}','#{teaser}','#{body}','#{external_debug}','#{external_source}','#{published}','#{published_at}','#{exported}','#{legacy_id}') on duplicate key update organization_ids=VALUES(organization_ids), community_id=VALUES(community_id), type_id=VALUES(type_id), headline=VALUES(headline), author=VALUES(author), teaser=VALUES(teaser), body=VALUES(body), external_debug=VALUES(external_debug), external_source=VALUES(external_source), published=VALUES(published), published_at=VALUES(published_at), exported=VALUES(exported), legacy_id=VALUES(legacy_id)")
			rescue
				next
			end
		end
	end
	if portion < 10000
		offset = -1
	else
		offset += 10000
	end
end


