File.open('region_list_output.txt', 'w') do |output|
File.open('region_list.txt', 'r') do |region_list|

  region_list.each do |line|
    output.puts line.chomp.sub(/(.*)\s+-\s+(.*)/, 's/\b\1\b/\2/ig;')
  end
end
end
