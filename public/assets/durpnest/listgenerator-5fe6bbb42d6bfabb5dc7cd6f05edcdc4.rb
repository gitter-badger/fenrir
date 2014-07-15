#listgenerator.rb

require 'mysql2'

local_client = Mysql2::Client.new(:host =>'localhost', :username => 'journatic', :password => 'journatic')
local_client.query('use bedrock')

stories_sites = Array.new
briefs_sites = Array.new
jnswire_communities = Array.new
output_sites = Array.new

File.open('../stories_ids.txt','r').each do |line|
  next if line.chomp == 'site_id'
  stories_sites << line.chomp
end

File.open('../briefs_ids.txt','r').each do |line|
  next if line.chomp == 'site_id'
  briefs_sites << line.chomp
end

local_client.query('select name from jnswire_jnswire_staging_communities').each{|n| jnswire_communities << n["name"]}

p stories_sites
p briefs_sites
p jnswire_communities

stories_sites.each do |entity|
  if briefs_sites.select{|w| w == entity} != []
  else
    output_sites << entity
  end
end

p output_sites
p output_sites.count

final = Array.new

output_sites.each do |site|
  sitename = local_client.query("select name from db05_games_list_websites where id=#{site}").first
  unless sitename == nil
    sitename = sitename["name"]
  end
  if jnswire_communities.select{|w| w == sitename} != []
  else
    final << sitename if sitename != nil
  end
end
    
p final
p final.count
