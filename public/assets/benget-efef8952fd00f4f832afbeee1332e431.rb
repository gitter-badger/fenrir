#gathers archaic stories, uniques them, associates them with organizations, stores them in pipeline.
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
to_check=0

local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

cluster = ''
correlary = ''
stories_orgs = ''
output = ''

commiehash = Hash.new

Net::SSH.start( HOST, USER, :password => PASS ) do |c2|


	
	#cluster = Targetfile.new(c13.exec!('mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e "select * from briefs limit 1"'))
	puts Time.now
	cluster = Targetfile.new(c2.exec!('mysql -udata_miner -pdata_miner -h cms CMS -e "select s.id, s.headline, s.teaser, s.text, s.author, s.created_at, s.updated_at, s.publishied_at, s.exported_at, p.id as project_id, p.name as project, t.id as type_id, t.name as type from stories s inner join types t on s.type_id=t.id inner join projects p on t.project_id=p.id where p.name not like \"%mmx%\" and p.id != 409"'))
	correlary = Targetfile.new(c2.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select * from stories\""))
	stories_orgs = Targetfile.new(c2.exec!("mysql -udata_miner -pdata_miner -h db05 games -e \"select * from stories_organizations\""))
	
	File.open('./durpnest/communities_manual_entry.txt', 'r').each do |line|
		commiehash[line.chomp.sub(/\t.*/, '')] = line.chomp.sub(/.*\t/, '')
	end

end
	
	#newcheck = Regexp.new(("\b\(#{local_client.query('select legacy_id from pipeline_stories').each.join('|')}\)\b"), Regexp::IGNORECASE)
	#p newcheck
	cluster.get_headers
	correlary.get_headers
	stories_orgs.get_headers
	to_check=cluster.count
	p Time.now - time
	
	time = Time.now
	orgs = Hash.new
	comms = Hash.new
	unique = Hash.new
	cluster.each do |chunk|
		#next if chunk['id'][newcheck]
			nomnom = correlary.select{|m| m['legacy_id'] == chunk['id']}
		next if nomnom == nil or nomnom.first == nil
		next if unique[chunk['id']] == 1
		unique[nomnom.first['legacy_id']] = 1
		organization_ids = Array.new
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
		exported = ''
		legacy_id = ''
		
		#puts ""
		#puts chunk['headline']
		
		if comms.has_key?(chunk['project'])
			#puts "sector 1"
			#organ = "#{chunk['project']} => #{comms[chunk['project']]}"
		elsif commiehash.has_key?(chunk['project'])
			comms[chunk['project']] = commiehash[chunk['project']]
		else
			correx = chunk['project'].sub(/.*-(.*)$/, '\1').gsub(/^ultimate/i, '').gsub(/(?<!\s|^)([A-Z])/, ' \1').sub(/^\s*/, '').sub(/\s*$/, '')
			#puts "sector 2: #{correx}"
			
			Net::SSH.start( DEEPHOST, USER, :password => PASS ) do |c13|
				output = c13.exec!("mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e \"select id from communities where name='#{correx}'\"")
			end
			#puts "sector 3"
			
			if output == nil or output == ''
				puts "#{chunk['project']} => \[id\]?\n"
				romp = gets.chomp
				comms[chunk['project']] = romp
				File.open('./durpnest/communities_manual_entry.txt', 'a') do |file|
					file.puts "#{chunk['project']}\t#{romp}"
				end
				output = ''
			elsif output != nil
				output.sub!(/.*\n/, '')
			end
			puts "sector 4"
			comms[chunk['project']] = output
			#organ = "#{chunk['project']} => #{output}"
			#puts "sector 5"
		end
		
		#puts organ
		#puts "money shot:"
		

			narf = stories_orgs.select{|s| s['story_id'] == chunk['id']}
			narf.each do |m|
				organization_ids << m['organization_id'].to_i
			end

		
		organization_ids = organization_ids.to_s
		organization_ids = 'NULL' if organization_ids == '' or organization_ids == nil
		
		community_id = comms[chunk['project']]
		community_id = 'NULL' if community_id == '' or community_id == nil

		type_id = chunk['type_id']
		type_id = 'NULL' if type_id == '' or type_id == nil
		#p "type_id:"
		#p type_id

		#p ""
		#p chunk['headline']
		headline = "#{chunk['headline']}".gsub(/(\'|\"|\#|\<|\>|\\|\/)/, '\\1')
		headline = 'NULL' if headline == '' or headline == nil
		#p "headline:"
		#p headline

		#p ""
		#p chunk['author']
		author = "#{chunk['author']}".gsub(/(\'|\"|\#|\<|\>|\\|\/)/, '\\1')
		author = 'NULL' if author == '' or author == nil
		#p "author:"
		#p author
		
		#p""
		#p chunk['teaser']
		teaser = "#{chunk['teaser']}".gsub(/(\'|\"|\#|\<|\>|\\|\/)/, '\\1')
		teaser = 'NULL' if teaser == '' or teaser == nil
		#p "teaser:"
		#p teaser
		
		#p ""
		#p chunk['text']
		body = "#{chunk['text']}".gsub(/(\'|\"|\#|\<|\>|\\|\/)/, '\\1')
		body = 'NULL' if body == '' or body == nil
		#p "body:"
		#p body
		
		external_debug = 'NULL'
		
		external_source = 'NULL'
		
		published = chunk['published']
		published = 'NULL' if published == '' or published == nil
		
		published_at = chunk['published_at']
		published_at = 'NULL' if published_at == '' or published_at == nil
		
		exported = 0
		legacy_id = chunk['id']
		legacy_id = 'NULL' if legacy_id == '' or legacy_id == nil

		system('clear')
		puts "remaining = #{to_check}"
		puts "x = #{x}"
		puts "legacy_id = #{legacy_id}"
		to_check-=1
		
		#puts "insert into pipeline_stories(organization_ids, community_id, type_id, headline, author, teaser, body, external_debug, external_source, published, published_at, exported, legacy_id) values('#{organization_ids}','#{community_id}','#{type_id}','#{headline}','#{author}',#{teaser}','#{body}','#{external_debug}','#{external_source}','#{published}','#{published_at}','#{exported}','#{legacy_id}') on duplicate key update organization_ids=VALUES(organization_ids), community_id=VALUES(community_id), type_id=VALUES(type_id), headline=VALUES(headline), author=VALUES(author), teaser=VALUES(teaser), body=VALUES(body), external_debug=VALUES(external_debug), external_source=VALUES(external_source), published=VALUES(published), published_at=VALUES(published_at), exported=VALUES(exported), legacy_id=VALUES(legacy_id)"
		begin
			local_client.query("insert into pipeline_stories(organization_ids, community_id, type_id, headline, author, teaser, body, external_debug, external_source, published, published_at, exported, legacy_id) values('#{organization_ids}','#{community_id}','#{type_id}','#{headline}','#{author}','#{teaser}','#{body}','#{external_debug}','#{external_source}','#{published}','#{published_at}','#{exported}','#{legacy_id}') on duplicate key update organization_ids=VALUES(organization_ids), community_id=VALUES(community_id), type_id=VALUES(type_id), headline=VALUES(headline), author=VALUES(author), teaser=VALUES(teaser), body=VALUES(body), external_debug=VALUES(external_debug), external_source=VALUES(external_source), published=VALUES(published), published_at=VALUES(published_at), exported=VALUES(exported), legacy_id=VALUES(legacy_id)")
		rescue
			next
		end
	end
	p Time.now - time
	p x

