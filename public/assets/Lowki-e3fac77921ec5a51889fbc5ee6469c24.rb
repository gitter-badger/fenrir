require 'mysql2'
require_relative('./storycreator.rb')
require_relative('./data_sanitation.rb')
require_relative('./procedures/higher_order_algorithms.rb')
require_relative('./procedures/dbtests.rb')

class Story
	attr_accessor :client,:offset,:where,:order,:limit
	def initialize(county_prefix, configuration, source_host, target_host, source_db, target_db, source_table, target_table, login, sanitation_assignments, export_arguments, ordering_key)
		@county_prefix = county_prefix
		@configuration = configuration
		@source_host = source_host
		@target_host = target_host
		@export = export_arguments
		@export = '' if @export == nil
		@source_db = source_db
		@target_db = target_db
		@source_table = source_table
		@target_table = target_table
		@args = sanitation_assignments
		@offset = @export.sub(/.* offset \b(\d+)\b.*/i, '\1').to_i
		if @export[/where /i]
			@where = @export.sub(/.*where (.*?) (?:limit.*$|offset.*$|order by .*$|$)/i, 'where \1')
		else
			@where = ''
		end
		
		@limit = @export.sub(/.* limit \b(\d+)\b.*/, '\1').to_i
		@ordering_key = ordering_key
		@limit = 1000 if @limit == 0
		@source_client = Mysql2::Client.new(:host => @source_host, :username => login['source_user'], :password => login['source_pass'])
		@target_client = Mysql2::Client.new(:host => @target_host, :username => login['target_user'], :password => login['target_pass'])
		puts "use #{@source_db}\;show keys from #{@source_table} where key_name='PRIMARY'"
		@source_client.query("use #{@source_db}")
		p "ordrz: #{@ordering_key}"
		if @ordering_key == nil
			puts "show keys from #{@source_table} where Key_name='PRIMARY'"
			@ordering_key = @source_client.query("show keys from #{@source_table} where Key_name='PRIMARY'").first['Column_name']
		end
		if @export[/order by/i]
			@order = @export.sub(/.*order by (.*?(?: desc| asc)?)(?: limit.*$| offset.*$|$)/i, 'order by \1')
		else
			@order = "order by #{@ordering_key}"
		end
	end
	
	def route
		@source_client.query("use #{@source_db}")
		@target_client.query("use #{@target_db}")
		puts "select * from #{@source_table} #{@where} #{@order}"
		puts @where
		puts @order
		portion = @source_client.query("select * from #{@source_table} #{@where} #{@order}")
		if portion.first == nil
		  puts "your selection from table #{@source_table} with export arguments \"#{@export}\" returned no lines of data.  Terminating run."
      exit(0)
    end
    all = portion.count
    while @offset >= 0
			RunLoki.clear_log(@county_prefix, @configuration)
			puts "select * from #{@source_table} #{@where} #{@order} limit #{@limit} offset #{@offset}"
			portion = @source_client.query("select * from #{@source_table} #{@where} #{@order} limit #{@limit} offset #{@offset}")
			
			total = portion.count
			
			x=0
			portion.each do |row|
				x+=1
				puts "#{all} <= #{@offset} :: #{x} / #{total}"
				
				@unique = @args['unique_key']
				
				@args.each do |target, args|
				  next if target == 'unique_key'
					args.each do |key, value|
						row[key] = '' if row[key] == nil
						@output = value[0].call(row[key], *value.last(value.count-1))
						#p @output
						@output.gsub!(/\\\s*$/, '')
						@output.sub!(/^\"{2,}(.*)\"{2,}$/, '"\1"')
						#puts @output
						@output = @output.gsub(/[\\]+(\"|\')/, '\1').gsub(/(\"|\'|\:|\#)/, '\\\\\1')
            #puts "update #{@target_table} set #{target} = '#{@output}' where #{@unique} = '#{row[@unique]}'"
            i = 5
            begin
							#p "update #{@target_table} set #{target} = '#{@output}' where #{@unique[-1]} = '#{row[@unique[0]].to_s.gsub(/(\'|\")/, '\\\\1')}'"
							@target_client.query("update #{@target_table} set #{target} = '#{@output}' where #{@unique[-1]} = '#{row[@unique[0]].to_s.gsub(/(\'|\")/, '\\\\1')}'")
						rescue
							i -= 1
							if i > 0
								puts "update query failed.  Retrying."
								retry
							else
								puts "update query failed after five attempts.  Aborting and raising exception."
							  raise
							end
						end
					end
				end
			end
			@offset += @limit
			@offset = -1 if @limit > portion.count
		end
	end
end


#below this line to be snipped soon.
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
		#.encode!('UTF-8', 'UTF-8', :invalid => :replace)
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

class Rules
    attr_reader :server, :user, :pass, :database, :table, :last_id, :headers, :nsalgs, :scalg
  def initialize (file)
    File.open("./lokirules/#{file}", 'r') do |contents|
      @server = contents.readline.sub(/.*=>\s*/, '').chomp
      @user = contents.readline.sub(/.*=>\s*/, '').chomp
      @pass = contents.readline.sub(/.*=>\s*/, '').chomp
      @database = contents.readline.sub(/.*=>\s*/, '').chomp
      @table = contents.readline.sub(/.*=>\s*/, '').chomp
      @last_id = contents.readline.sub(/.*=>\s*/, '').chomp.to_i
      @headers = contents.readline.sub(/.*=>\s*/, '').chomp.split(/\s*,\s*/)
      @nsalgs = contents.readline.sub(/.*=>\s*/, '').chomp.split(/\s*,\s*/)
      @scalg = contents.readline.sub(/.*=>\s*/, '').chomp
    end
  end
end

def load_dataset(user, pass, server, database, tables)
  client = Mysql2::Client.new(:host => server, :username => user, :password => pass)
  client.query("USE #{database}")
  quary = Array.new
  tables.each do |table|
    quary << client.query("SELECT * FROM #{table}")
  end
  return quary
end

def loadloki (input)
  law = Rules.new("#{input}_rules.txt")  #reads the rules associated with this file
  client = Mysql2::Client.new(:host => law.server, :username => law.user, :password => law.pass)
  client.query("USE #{law.database}")
  quary = client.query("SELECT * FROM #{law.table} WHERE id > #{law.last_id}")
  if (law.scalg =~ /\;|system|\(|\)|drop/)
    abort("nice try, MacGuyver.")
  end
  nsalgs = Hash[ law.headers.zip(law.nsalgs) ]
  p "scalg: #{law.scalg}"
  cleantable = eval("#{law.scalg}(nsalgs, quary)")
end

def hyperlocal_montgomery_arrests_data
  client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
  client.query('USE bedrock')
  client.query("CREATE TABLE IF NOT EXISTS hyperlocal_montgomery_arrests_data_stories (id INT PRIMARY KEY, charges INT, story TEXT CHARACTER SET utf8)")
  p client.query("show tables")
  data = client.query('SELECT * from hyperlocal_montgomery_arrests_data')
  data_charges = client.query('SELECT * from hyperlocal_montgomery_arrests_data_charges')
  

  logic = Gen7logic.new('gen7charges.tsv')
  logic.grow_tree

  x = 0
  total = data.count
  if File.exist?('./stories/last_id/hyperlocal_montgomery_arrests_data')
    last_id = File.open('./stories/last_id/hyperlocal_montgomery_arrests_data', 'r').readline.chomp.to_i
  else
    last_id = 0
  end
  data.each do |line|
    x+=1
    next if line['id'] <= last_id
    time1 = Time.now
    relevant_charges = data_charges.select{|line2| line2['record_id'].to_i == line['id'].to_i}
    #storyout = File.open("./stories/hyperlocal_montgomery_arrests_data_>_#{line['id']}_>_#{line['arrest_date']}#{nameswap(line['name'])}.txt", 'w')
    
    crimes = Array.new
    
    relevant_charges.each do |story_data|
      crimes << story_data['charge']
    end
    #storyout.puts "id: #{line['id']}"
    #storyout.puts "charges: #{relevant_charges.count}"
    storyout = "On #{date_standardization(line['arrest_date'])}, #{nameswap(line['name']).gsub(/(\"|\')/, '\\\\\1')} was #{crimelist(crimes, logic).gsub(/(\"|\')/, '\\\\\1')}"
    #system('clear')
    print "\n#{x}/#{total}"
    #puts "INSERT INTO hyperlocal_montgomery_arrests_data_stories(id, charges, story) VALUES(#{line['id'].to_i}, #{relevant_charges.count.to_i}, \'#{storyout}\') on duplicate key update charges = VALUES(charges) story = VALUES(story)"
    client.query("INSERT INTO hyperlocal_montgomery_arrests_data_stories(id, charges, story) VALUES(#{line['id'].to_i}, #{relevant_charges.count.to_i}, \'#{storyout}\') on duplicate key update charges = VALUES(charges), story = VALUES(story)")
    #needs a method to continue if a sql syntax error is returned, filing the failed ID in an array.
    
    print ":: #{Time.now - time1}"
    File.open('./stories/last_id/hyperlocal_montgomery_arrests_data', 'w'){|file| file.puts line['id']}
  end
end

def hyperlocal_belvidere_police_arrests
  client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
  client.query('USE bedrock')
  client.query("CREATE TABLE IF NOT EXISTS hyperlocal_belvidere_police_arrests_stories (id INT PRIMARY KEY, date VARCHAR(10), name VARCHAR(60), sex VARCHAR(10), age INT, race VARCHAR(10), officer_name VARCHAR(60), charge TEXT CHARACTER SET utf8, story TEXT CHARACTER SET utf8)")
  p client.query("show tables")
  data = client.query('SELECT * from hyperlocal_belvidere_police_arrests')

  logic = Gen7logic.new('gen7charges.tsv')
  logic.grow_tree

  x = 0
  total = data.count
  if File.exists?('./stories/last_id/hyperlocal_belvidere_police_arrests')
    last_id = File.open('./stories/last_id/hyperlocal_belvidere_police_arrests').readline.chomp.to_i
  else
    last_id = 0
  end
  data.each do |line|
    x+=1
    untweaked = "#{line['date']}"
    next if line['id'] <= last_id
    time1 = Time.now

    storyout = "On #{date_standardization(line['date'])}, #{line['name'].gsub(/(\"|\')/, '\\\\\1').gsub(/^\s*-BLANK-\s*$/, 'an unspecified individual')} was arrested on charges of #{rungen7(logic, line['charge']).gsub(/(\"|\')/, '\\\\\1')}."
    storyout.sub(/charges of -BLANK-/, 'unspecified charges')
    if(line['race'] =~ /\bblack\b/i)
		date_end = untweaked.gsub(/-/, '')
		date_start = date_end.gsub(/\b(\d{4})(\d{2})(\d{2})\b/){|date|
		  y = date.sub(/\b(\d{4})(\d{2})(\d{2})\b/, '\1')
		  m = date.sub(/\b(\d{4})(\d{2})(\d{2})\b/, '\2')
		  d = date.sub(/\b(\d{4})(\d{2})(\d{2})\b/, '\3')
		  m = "0#{m.to_i - 1}" if m.to_i < 11
		  m = "#{m.to_i - 1}" if m.to_i >= 11
		  "#{y}#{m}#{d}"
		  }
		date_start = date_start.to_i
		date_end = date_end.to_i
		storyout = storyout + "  #{hyperlocal_belvidere_police_arrests_racial(date_start, date_end)}"
	end
    print "\n#{x}/#{total}"
    client.query("INSERT INTO hyperlocal_belvidere_police_arrests_stories(id, date, name, sex, age, race, officer_name, charge, story) VALUES(#{line['id'].to_i}, \'#{untweaked}\', \'#{nameswap(line['name']).gsub(/(\"|\')/, '\\\\\1')}\', \'#{line['sex']}\', #{line['current_age'].to_i}, \'#{line['race']}\', \'#{nameswap(line['arresting_officer_name']).gsub(/(\"|\')/, '\\\\\1')}\', \'#{line['charge']}\', \'#{storyout}\') on duplicate key update date = VALUES(date), name = VALUES(name), sex = VALUES(sex), age = VALUES(age), race = VALUES(race), officer_name = VALUES(officer_name), charge = VALUES(charge), story = VALUES(story)")
    print ":: #{Time.now - time1}"
    File.open('./stories/last_id/hyperlocal_belvidere_police_arrests', 'w'){|file| file.puts line['id']}
  end
end

def hyperlocal_belvidere_police_arrests_racial(time1, time2)
	client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
  client.query('USE bedrock')
  data = client.query('SELECT * from hyperlocal_belvidere_police_arrests_stories')
  
  #total = data.count
  #time1 = Time.now
  #time1 = time1.to_s
  #time2 = time1.sub(/(?<=-)(\d{2})(?=-)/){|n| n = n.to_i; if(n >= 11); "#{n-1}"; else; "0#{n-1}"; end;}
  #time1.to_s.sub!(/^([^\s]+).*/, '\1'); time2.to_s.sub!(/^([^\s]+).*/, '\1')
  
  #time1 = '20120314'
  #time2 = '20130314'
  
  
  selection = data.select{|line| line['date'].gsub(/-/, '').to_i >= time1.to_i and line['date'].gsub(/-/, '').to_i <= time2.to_i}
  partial = selection.count
  black = selection.select{|line| line['race'] == 'black'}
  racial = black.count
  float = (racial.to_f / partial) * 100
  output = "%0.2f" % float
  
  return "Between #{date_standardization(time1.to_s.sub(/(\d{4})(\d{2})(\d{2})/, '\1-\2-\3'))} and #{date_standardization(time2.to_s.sub(/(\d{4})(\d{2})(\d{2})/, '\1-\2-\3'))}, #{output.sub(/0*\s*$/, '')}% of all individuals arrested in Belvidere were African American."
end

def sample_set1
  client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
  client.query('USE bedrock')
  client.query("CREATE TABLE IF NOT EXISTS sample_set1_stories (id INT PRIMARY KEY, date VARCHAR(10), name VARCHAR(60), sex VARCHAR(10), age INT, race VARCHAR(10), last_known_street TEXT CHARACTER SET utf8, officer VARCHAR(60), beat VARCHAR(10), beat_zip VARCHAR(15), charge TEXT CHARACTER SET utf8, story TEXT CHARACTER SET utf8)")
  data = client.query('SELECT * from sample_set1')

  logic = Gen7logic.new('gen7charges.tsv')
  logic.grow_tree

  x = 0
  total = data.count
  if File.exists?('./stories/last_id/sample_set1')
    last_id = File.open('./stories/last_id/sample_set1').readline.chomp.to_i
  else
    last_id = 0
  end
  
  data.each do |line|
    x+=1
    untweaked = "#{line['date']}".gsub(/\b(\d{1})\b/, '0\1')
    next if line['id'].to_i <= last_id
    time1 = Time.now

    print "\n#{x}/#{total}"
    chargeout = "#{rungen7(logic, line['charge'])}"
    
    storyout = "On #{date_standardization(line['date'])}, #{nameswap(line['name'])} was arrested on charges of #{chargeout}"

    client.query("INSERT INTO sample_set1_stories(id, date, name, sex, age, race, last_known_street, officer, beat, beat_zip, charge, story) VALUES(#{line['id'].to_i}, \'#{untweaked}\', \'#{nameswap(line['name']).gsub(/(\"|\')/, '\\\\\1')}\', \'#{line['sex']}\', #{line['current_age'].to_i}, \'#{line['race']}\', \'#{line['last_known_street'].gsub(/(\"|\')/, '\\\\\1')}\', \'#{nameswap(line['officer']).gsub(/(\"|\')/, '\\\\\1')}\', \'#{line['beat']}\', \'#{line['beat_zip']}\', \'#{chargeout}\', \'#{storyout}\') on duplicate key update date = VALUES(date), name = VALUES(name), sex = VALUES(sex), age = VALUES(age), race = VALUES(race), last_known_street = VALUES(last_known_street), officer = VALUES(officer), beat = VALUES(beat), beat_zip = VALUES(beat_zip), charge = VALUES(charge), story = VALUES(story)")
    print ":: #{Time.now - time1}"
    File.open('./stories/last_id/sample_set1', 'w'){|file| file.puts line['id']}

  end
  
end

def sample_set1_linegraph_crime_type
  client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
  client.query('USE bedrock')
  data = client.query('SELECT * from sample_set1_stories')
  client.query('CREATE TABLE IF NOT EXISTS sample_set1_stories_linegraph_crime_type(id INT PRIMARY KEY, date VARCHAR(15), violent INT, nonviolent INT)')
  
  datapoints = Hash.new
  
  x = 0
  y = data.count
  data.each do |line|
		x+=1
		point = "#{line['date']}"
		datapoints[point] = [] unless datapoints[point].is_a?(Array)
		datapoints[point] << line['charge']
		puts "#{x} / #{y} :: #{datapoints[line['date']].count}"
	end
  x = 19900000
  y = 0
  until x > 20201231
		x+=1
		
		key = x.to_s.sub(/(\d{4})(\d{2})(\d{2})/, '\1-\2-\3')		
		next unless datapoints.has_key?(key)
		y+=1
		violent = datapoints[key].select{|n| n =~ /\bassault|murder|robbery|rape\b/i}.count
		nonviolent = datapoints[key].count - violent
		
		client.query("INSERT INTO sample_set1_stories_linegraph_crime_type(id, date, violent, nonviolent) VALUES(#{y}, \'#{key}\', #{violent}, #{nonviolent}) ON DUPLICATE KEY UPDATE id = VALUES(id), date = VALUES(date), violent = VALUES(violent), nonviolent = VALUES(nonviolent)")
		puts y
	end
  
end

def reset_last_id
	id = gets.chomp.to_i
	File.open('./stories/last_id/sample_set1', 'w') do |file|
		file.puts id
	end
end



