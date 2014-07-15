#!/usr/bin/env /usr/local/rvm/wrappers/ruby-2.0.0-p353/ruby
#!/usr/bin/env ruby

#for local testing switch order of shebangs
$STORE_PATH = File.expand_path(__FILE__).sub(/\/Loki.rb\s*$/, '')
$TEST = 0

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end
def blue(text); colorize(text, 34); end
def lblue(text); colorize(text, 36); end

require_relative './trigger.rb'

login_credentials = Hash.new('')
login_credentials['source_user']=''
login_credentials['source_pass']=''
database_default_user=''
database_default_pass=''

if Dir["/data_miner/ini/"] != nil and Dir["/data_miner/ini/"] != []
	File.open("/data_miner/ini/db.ini", 'r') do |dbini|
		onflag = 0
		dbini.each do |line|
			if line =~ /^\s*\[database\]\s*$/
				onflag = 1
				next
			end
			next unless onflag == 1
			if line =~ /^\s*user=/
				login_credentials['source_user']=line.sub(/^\s*user=(.*)$/, '\1').chomp
				database_default_user = login_credentials['source_user']
			elsif line =~ /^\s*password=/
				login_credentials['source_pass']=line.sub(/^\s*password=(.*)$/, '\1').chomp
				database_default_pass = login_credentials['source_pass']
			end
			onflag = 0 if line =~ /^\[/
		end
	end
end

ARGV.each do |testseek|
	if testseek[/--test/i]
		$TEST = 1
	end
end

if ARGV[0][/^\{/]
	StringLoki.new(ARGV)
elsif ARGV[0][/^--h(elp)?/i]
	puts __FILE__
	puts $STORE_PATH
	Dir.chdir($STORE_PATH)
	puts Dir.pwd
	File.open('help.txt', 'r').each do |line|
		if line[/^==/]
			line = lblue(line)
		elsif line[/^\>/]
			line = green(line)
		elsif line[/^  [^\s]/]
			line = yellow(line)
		end
		puts line
	end
elsif ARGV[0][/^\_/]
	flag = 0
	ARGV.each do |command|
		if command[/^\s*local\s*$/]
			puts "local run identified"
			flag = 1
		end
	end
	if flag == 1
		held = ARGV.reject{|item| item[/^_/]}
		puts "fetching configurations"
	  client = Mysql2::Client.new(:host => 'localhost', :username => 'journatic', :password => 'journatic')
		client.query("use bedrock")
		configurations = client.query("select * from procedures where cluster=#{ARGV[0].sub(/^\_/,'')}")
		p configurations
		configurations.each do |config|
			argv = [":#{config['county_prefix']}@#{config['configuration']}"]
			argv = argv + held
			p argv
			p held
			RunLoki.new(argv)
		end
	else
		held = ARGV.reject{|item| item[/^_/]}
		puts "fetching configurations"
		#these are defined in trigger.rb, which has been loaded
		client = Mysql2::Client.new(:host => 'c13', :username => database_default_user, :password => database_default_pass)
		client.query("use core")
		configurations = client.query("select * from Loki_procedures where cluster=#{ARGV[0].sub(/^\_/,'')}")
		p configurations
		configurations.each do |config|
			argv = [":#{config['county_prefix']}@#{config['configuration']}"]
			argv = argv + held
			p argv
			p held
			RunLoki.new(argv)
		end
	end
elsif ARGV[0][/^\%/]
	load("#{$STORE_PATH}/higher_order_algorithms.rb")
	w = ARGV[0].sub(/^\%/, '')
	if w[/^x?\d+$/]
		w = hle_router(w)
	elsif w =~ /^\:/ and w =~ /\./
		w = Object.const_get("#{w.sub(/^\:(.*)\.[^,]+/, '\1')}")::method("#{w.sub(/^\:.*\.([^,]+)/, '\1')}")
	elsif w =~ /^\:\$/
		w = $global.local_variable_get(:"#{w.sub(/\:\$/, '')}")
	elsif w =~ /^\:/
		w = method(:"#{w.sub(/\:/, '')}")
	elsif w =~ /^\d{1,}$/
		w = w.to_i
	end
	$terminal_flag = 0
	$testing = 0
	ARGV.each{|argument|
	if argument =~ /^-t(ermi?n?a?l?)?$/
		$terminal_flag = 1
	end
	if argument =~ /^-x$/
		$testing = 1
	end
	}
	puts "terminal? #{$terminal_flag}"
	unless $terminal_flag == 1
		$stderr.reopen(File.new("#{$HIGHER_ORDER_PATH}/logs/higher_order.err", 'w'))
		$stdout.reopen(File.new("#{$HIGHER_ORDER_PATH}/logs/higher_order.log", 'w'))	
	end
	w.call(*ARGV.last(ARGV.count-1))
else
	RunLoki.new(ARGV)
end

