
puts Dir.pwd
Dir.chdir('/home/mamanbrigitte/Downloads/')
puts Dir.pwd

filename='houston_streets'

File.open("#{filename}_NS.txt",'w') do |output|
File.open("#{filename}.txt", 'r').each do |line|
	output.puts line.sub(/\t/, '  ') unless line[/NULL/]
end
end
