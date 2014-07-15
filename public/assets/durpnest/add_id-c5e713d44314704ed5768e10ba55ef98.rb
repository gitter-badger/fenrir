output = File.open('sample_set1x.tsv', 'w') do |output|
file = File.open('sample_set1.tsv', 'r') do |file|
  x = 0
  file.each do |line|
    output.puts line if line =~ /^\s*id/
    x += 1
    output.puts "#{x}\t#{line}"
  end
end
end

File.delete('sample_set1.tsv')
File.rename('sample_set1x.tsv', 'sample_set1.tsv')
