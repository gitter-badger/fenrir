
require_relative('Lowki.rb')
	
def lake_fl_ocr_control(string)
	array = string.split(/\&?\|\|/)
	array.each_index do |i|
		#if it is not a business and the last word is one character long, the first word is almost certainly a last name.
		#if the first word has been a last name somewhere else in the string, it is likely also a last name.
		#ideally, if the first word has been a last name anywhere in the prior entries, this should be remembered.
		#you might accomplish this either with a class definition or a global array.
	end
end


def assign_sanitation(argument, sanitation_assignments)
	array = argument.sub(/^\"?args\{(.*)\}\s*\"?\s*$/, '\1').split(/\s*\},\s*/)
	array.each do |arg|
    puts arg.class

		if arg =~ /\'?unique_key\'?\s*=>/
			key = 'unique_key'
			value = arg.sub(/.*=>\s*(.*)/, '\1')
			sanitation_assignments[key] = value
		else
			key = arg.sub(/(.*)\s*=>\s*\{([^\{\}]+)\}?\s*$/, '\1').sub(/\s*$/, '').sub(/^\s*/, '')
			sanitation_assignments[key] = Hash.new
			arrayinner = arg.sub(/.*=>\s*\{([^\{\}]+)\}?\s*$/, '\1').split(/\s*=>\s*/)
			key_inner = arrayinner[0]
			sanitation_assignments[key][key_inner] = Array.new
      p arrayinner
			arrayinner[1].split(/,/).each do |w|
					w.sub!(/^\s*/, '')
					w.sub!(/\s*$/, '')
					if w =~ /^\:/ and w =~ /\./
						w = Object.const_get("#{w.sub(/^\:(.*)\.[^,]+/, '\1')}")::method("#{w.sub(/^\:.*\.([^,]+)/, '\1')}")
					elsif w =~ /^\:\$/
						w = $global.local_variable_get(:"#{w.sub(/\:\$/, '')}")
					elsif w =~ /^\:/
						w = method(:"#{w.sub(/\:/, '')}")
					elsif w =~ /^\d{1,}$/
						w = w.to_i
					end
					sanitation_assignments[key][key_inner] << w
			end
		end
	end
	return sanitation_assignments
end
