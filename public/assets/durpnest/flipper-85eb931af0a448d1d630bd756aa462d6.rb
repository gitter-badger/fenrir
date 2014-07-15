File.open('output.txt', 'w') do |output|
File.open('input.txt', 'r') do |input|
  input.each do |line|
    line = line.chomp
    output.puts "\\b#{line.sub(/.*\t/, '')}\\b\t#{line.sub(/\t.*/, '')}"
  end
end
end
