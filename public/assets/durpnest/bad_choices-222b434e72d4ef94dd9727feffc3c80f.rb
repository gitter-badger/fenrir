def establish_tests(algorithm)
	Dir.chdir($HIGHER_ORDER_PATH)
	unless File.directory?("./test_kits/#{algorithm}")
		Dir.mkdir("./test_kits/#{algorithm}")
		File.new("./test_kits/#{algorithm}/tests.#{algorithm}.txt", 'a')
	end
end

def read_tests(algorithm)
	Dir.chdir($HIGHER_ORDER_PATH)
	existing = Hash.new
	File.open("./test_kits/#{algorithm}/tests.#{algorithm}.txt", 'r') do |file|
		file.each do |line|
			existing[line.sub(/\t.*/, '')] = line.sub(/.*\t/, '')
		end
	end
	return existing
end

def add_tests(algorithm, input_hash)
	Dir.chdir($HIGHER_ORDER_PATH)
	tests = read_tests(algorithm)
	changes = Hash.new
	File.open("./test_kits/#{algorithm}/tests.#{algorithm}.txt", 'a') do |file|
		input_hash.each do |key, value|
			if !tests[key]
				file.puts "#{key}\t#{value}"
			elsif tests[key] != value
				changes[key] = [tests[key], value]
			end
		end
	end
	File.open("./test_kits/#{algorithm}/conflicts.#{algorithm}.txt", 'a') do |conflicts|
		changes.each do |key, value|
			conflicts.puts "#{key}\t#{value[0]}\t#{value[1]}"
		end
	end
end

def run_tests(algorithm)
	Dir.chdir($HIGHER_ORDER_PATH)
	tests = read_tests(algorithm)
	changes = Hash.new
	tests.each do |key, value|
		output = algorithm(key)
		unless output == value
			changes[key] = [output, value]
		end
	end
end

