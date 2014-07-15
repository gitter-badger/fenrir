File.open('output.txt', 'w') do |output|
File.open('abbreviated_streets.tsv', 'r') do |file|
  file.each do |line|
    line = line.gsub(/[";]+/, "\n")
    line = line.sub(/\t/, '  :::  ')
    output.puts line
  end
end
end
