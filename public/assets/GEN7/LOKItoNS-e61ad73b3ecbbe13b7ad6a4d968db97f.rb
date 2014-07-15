File.open('gen7charges.txt', 'w') do |output|
File.open('gen7charges2.tsv', 'r').each do |line|

line = line.gsub(/\t/, '    ')

output.puts line

end
end
