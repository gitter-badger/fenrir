

street_hash=Hash.new

File.open('hamilton_streets.txt','r').each do |street|
	array = street.chomp.split(/\t/)
	street_hash[array[0]] = array[1]
end

p street_hash
