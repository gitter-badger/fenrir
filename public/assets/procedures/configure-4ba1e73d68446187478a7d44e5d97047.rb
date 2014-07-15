
puts "target fields:"
targets = gets.chomp.split(/,/)
puts "unique link (source > target):"
l = gets.chomp.split(/>/)
link = Hash.new
link[:source] = l[0]
link[:target] = l[1]

def methodize(string)
	if w =~ /^\:/ and w =~ /\./
		w = Object.const_get("#{w.sub(/^\:(.*)\.[^,]+/, '\1')}")::method("#{w.sub(/^\:.*\.([^,]+)/, '\1')}")
	elsif w =~ /^\:\$/
		w = $global.local_variable_get(:"#{w.sub(/\:\$/, '')}")
	elsif w =~ /^\:/
		w = method(:"#{w.sub(/\:/, '')}")
	elsif w =~ /^\d{1,}$/
		w = w.to_i
	end
	
	return w
end

targets.each do |t|
	puts "constructor method for #{t}:"
	method = methodize(gets.chomp.strip)
	target_host = t.sub(/([^\.]+)\..*/, '\1')
	target_database = t.sub(/[^\.]+\.([^\.]+)\..*/, '\1')
	target_table = 
	#puts "arguments for constructor method (blank for string):"
	arguments = "
end
