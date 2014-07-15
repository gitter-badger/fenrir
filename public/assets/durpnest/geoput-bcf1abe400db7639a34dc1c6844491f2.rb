
require 'mysql2'
require 'highline/import'
require 'net/ssh'
#require 'net/http'
require 'rest_client'
require 'json'
require_relative '../Lowki.rb'

local_client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

derfderf = local_client.query('select * from pipeline_stories where organization_ids not like \'[9999999990%\' and community_id not like \'9999999990%\'')


Net::SSH.start( 'c13.blockshopper.com', 'ghuestis', :password => '' ) do |ssh|
	derfderf.each do |derf|
		
		bool = TRUE
		nerf = ssh.exec!("mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e \"select o.organization_id, s.cms_story_id from stories s join organizations_stories o where s.cms_story_id = #{derf['legacy_id']} and s.cms_story_id = o.story_id\"")
		unless nerf == nil
			nerf = Targetfile.new(nerf)
			nerf.get_headers
			nerf.each do |org|
				p "#{org} || #{derf['organization_ids']}"
				if org['organization_id'] != '0'
					bool = FALSE
				end
			end
		
		
			
		
			if bool == TRUE
				this = ssh.exec!("mysql -uapp -p4pp -h jnswire2.c2ygbkoa3qma.us-east-1.rds.amazonaws.com jnswire_staging -e \"select id from stories where cms_story_id=#{derf['legacy_id']} group by id\"")
				this = this.sub(/.*\n(.*)\n/, '\1')
				puts this
				puts "..."
				puts derf['organization_ids']
				#narfle = derf['organization_ids'].sub(/^[(.*)]$/, '\1').split(/\s*,\s*/) 
				query = {	'organization_ids' => derf['organization_ids'] }
								#"community_id='#{derf['community_id']}', "\
								#"type_id='#{derf['type_id']}', "\
								#"headline='#{derf['headline']}', "\
								#"author='#{derf['author']}', "\
								#"teaser='#{derf['teaser']}', "\
								#"body='#{derf['body']}', "\
								#"external_debug='#{derf['external_debug']}', "\
								#"external_source='#{derf['external_source']}', "\
								#"published='#{derf['published']}', "\
								#"published_at='#{derf['published_at']}'"
				p nerf
				puts "#{derf['legacy_id']} || #{this}"
				pod = { :organization_ids => derf['organization_ids']}
				p pod
				access_key = 'ixvybsXx9xSM3WRjjxsm'
				p "https://pipeline-staging.locallabs.com/api/v1/stories/#{this}.json?access_key=#{access_key}"
				wait = gets
				
				#response = Net::HTTP.post_form("https://pipeline-staging.locallabs.com/api/v1/stories/#{this}?access_key=ixvybsXx9xSM3WRjjxsm", query)
				#uri = URI("https://pipeline-staging.locallabs.com/api/v1/stories/#{this}?access_key=ixvybsXx9xSM3WRjjxsm")
				#http = Net::HTTP.new(uri.host, uri.port)
				#http.use_ssl = true
				#http.verify_mode = OpenSSL::SSL::VERIFY_NONE
				#request = Net::HTTP::Put.new(uri, query)
				#response = http.request request
				
				
				
				
				url = "https://pipeline-staging.locallabs.com/api/v1/stories/#{this}.json?access_key=#{access_key}"
				response = RestClient.get url
				puts response
				
				puts JSON.parse(response)['organization_ids']
				puts JSON.parse(response)['images']
				#returns 404 resource not found:
				begin
					response = RestClient.put url, pod, :content_type => :json, :accept => :json
					puts response
				rescue
					next
				end
				response = RestClient.get url
				puts JSON.parse(response)['organization_ids']
				
			end
		end
	end
end



#response = http.post('/api/vi/stories?ixvybsXx9xSM3WRjjxsm', query)
