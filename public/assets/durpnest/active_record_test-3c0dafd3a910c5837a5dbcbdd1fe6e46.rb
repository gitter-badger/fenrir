
require 'mysql2'
require 'active_record'


ActiveRecord::Base.establish_connection(
  :adapter => "mysql2",
  :host  => "localhost",
  :database => "bedrock",
  :username => "journatic",
  :password => "journatic"
)

class C3_cook_il_tagging_deeds < ActiveRecord::Base
end

data = C3_cook_il_tagging_deeds.new

dataset = C3_cook_il_tagging_deeds.all.find_each{|line|
	
}


#time1 = Time.now
#data.each do |line|
#	puts line.to_s
#end
#puts Time.now - time1



