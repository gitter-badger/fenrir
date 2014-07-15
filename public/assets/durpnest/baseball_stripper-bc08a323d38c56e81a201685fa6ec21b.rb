
positions = Array.new

File.open('baseball_positions.txt','r').each do |line|
	positrons = line.split(/\//)
	p positrons
	positrons.each do |item|
		positions << item
	end
end

positions = positions.uniq

puts positions
