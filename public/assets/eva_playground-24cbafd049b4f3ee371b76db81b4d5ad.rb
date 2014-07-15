require 'mysql2'
require_relative './Lowki.rb'

client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')

def grantors_and_grantees(grantors, grantees)
	gors = 'grantor'
	gees = 'grantee'
	gors = gors + 's' if grantors =~ /\|\|/
	gees = gees + 's' if grantees =~ /\|\|/
end

client.query('use bedrock')
data = client.query("select * from db04_westport_ct_tagging_deeds where date > '2013' order by date desc limit 100")

data_array = Array.new
data.each do |line|
  data_array << line
end

data_array.each do |hash|
  puts "this is a real estate story about #{grantors_and_grantees(hash['grantor_big'],hash['grantee_big'])}"
end
