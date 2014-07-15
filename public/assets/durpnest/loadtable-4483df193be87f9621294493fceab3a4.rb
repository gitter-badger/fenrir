require 'mysql2'

class Targetfile
  include Enumerable
  
  attr_accessor :inputfile, :headers, :input_array
  
  def initialize(file)
    if file =~ /\n/
      @inputfile = StringIO.new(file)
    else
      puts Dir.pwd
      @input_array = false
      @inputfile = File.open(file, 'r')
    end
  end
  
  def get_headers
    @inputfile.rewind
    @input_array = Array.new
    @headers = inputfile.first.chomp.split(/\t/)
    @inputfile.each do |line|
      self.assign_row(line)
    end
  end
  
  def assign_row(line)
    row_array = line.chomp.split(/\t/)
    @input_array << Hash[ @headers.zip(row_array) ]
  end

  def send_build
    @input_array || self.get_headers
  end
	
  def each
    self.send_build.each {|row| yield row}
  end

end

print "\n filename:\n";
file = gets.chomp;

target = Targetfile.new(file);

target.get_headers;
client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
client.query("use bedrock");

puts target.headers
length = Hash.new
quary = ''

target.each do |item|

  target.headers.each do |header|
    puts "...#{header} => #{item[header]}"
    if item[header] != nil
		length[header] = item[header].length if length[header] == nil or item[header].length > length[header]
	end
  end
end

target.headers.each do |header|
  puts "#{header} => #{length[header]}"
  while (length[header] % 10 != 0) do
    length[header] = length[header] + 1
  end
  puts "table size for #{header} ===> #{length[header]}"
  if(header == 'id')
    quary = quary + "#{header} MEDIUMINT, "
  elsif(header == 'date' or header == 'exported_at' or header == 'updated_at')
		quary = quary + "#{header} DATE, "
	else
    quary = quary + "#{header} VARCHAR(#{length[header]}), "
  end
end

file.sub!(/\.txt|\.tsv|\.csv/, '');
file.gsub!(/\./, '_');

print "\n\n #{quary}"
quary.sub!(/,\s*$/, '');
print "\n\n #{quary} \n.................................\n"
completequary = "CREATE TABLE IF NOT EXISTS #{file} (#{quary});"

print "\n\n #{completequary}"
client.query("#{completequary}");


target.each do |item|
  quary = '';
  target.headers.each do |header|
    if item[header] != nil and item[header].match(/\\/)
      item[header].gsub!(/\\/, '\\\\\\\\')
    end
    if header == 'id'
      quary = quary + "#{item[header]}, "
    elsif item[header] != nil
      quary = quary + "'#{item[header].gsub(/(')/, '\\\\\1')}', "
    elsif item[header] == nil
      quary = quary + "'', "
    end
  end
  quary.sub!(/,\s*$/, '')
  puts "\n\n INSERT INTO #{file} VALUES (#{quary});"
  client.query("INSERT INTO #{file} VALUES (#{quary});");
end

#client.query("load data local infile './#{file}' into table #{file}");
