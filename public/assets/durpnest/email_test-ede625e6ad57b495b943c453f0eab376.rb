
require 'net/smtp'

def expand_hash(hash)
	output = "key\t|output\n###########################################\n"
	hash.each do |key, value|
		output = output + "#{key}\t\|#{value}\n-------------------------------------------\n"
	end
	return output
end

def defaulted_emails(algorithm, hash)
	message = "
From: Loki <lokidts@gmail.com>
To: You
Subject: LOKI - #{algorithm} - GEN7 defaults
	
#{algorithm} was run and defaulted on the following items:
==========================================================
#{expand_hash(hash)}
"
	
	smtp = Net::SMTP.new 'smtp.gmail.com', 587
	smtp.enable_starttls
	puts message
	
	smtp.start('gmail.com','lokidts@gmail.com','correctdogbatterystaple', :plain) do |smtp|
	  smtp.send_message message, 'lokidts@gmail.com', 
	                             'george.huestis@locallabs.com'
	end
end
#message = "
#From: Loki <lokidts@gmail.com>
#To: You
#Subject: LOKI - #{algorithm} - unexpected results

#{algorithm} tests which produced unexpected results
#====================================================
#"
