
require_relative('../Lowki.rb')
client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')

#nsdat = Targetfile.new('c3.will_il_tagging.deeds.txt')
#nsdat.get_headers
nsdat = File.open('c3.will_il_tagging.deeds.txt')

puts "file loaded"

client.query('use bedrock')
#lokidat = client.query('select * from c3_will_il_tagging_deeds')

puts "loki data loaded"

test = Hash.new(0)
rand = Random.new
headers = nsdat.gets.chomp.split(/\t/)

#lokidat.each do |line|

while(ns_line = nsdat.gets.chomp)
	next unless rand(10) == 9
	ns_line_array = ns_line.split(/\t/)
	ns_line_hash = Hash[ headers.zip(ns_line_array) ]
	identity = ns_line_hash['doc_number']
	puts "#{identity}"
	puts "#{ns_line_hash['grantor_big']}"
	puts "NS <-:#{ns_line_hash['grantor_together']} |-| #{client.query("select grantor_together from c3_will_il_tagging_deeds where doc_number = '#{identity}'").first['grantor_together']}:-> Loki"
	check = gets.chomp
	test[check]+=1
	total = test['1'].to_f + test['2'].to_f + test['3'].to_f
	puts "Loki preferred in #{(test['2'].to_f / total).round(4) * 100} percent of cases."
	puts "Equivalence in #{(test['3'].to_f / total).round(4) * 100} percent of cases."
	puts "NS preferred in #{(test['1'].to_f / total).round(4) * 100} percent of cases."
	puts "#{total} total cases."
end

