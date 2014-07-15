
puts "File to be hunted: "
file = gets.chomp

puts Dir.pwd
until File.exists?(file) do
  puts "File not found.  File to be hunted: "
  file = gets.chomp
end

File.open("selection_from_#{file}", 'w') do |output|
File.open(file, 'r') do |input|

  input.each do |line|
    if line.match(/\bunit\b|\bapt\b\.?|\bapartment\b|\#/)
      output.puts line
    end
  end
end
end
