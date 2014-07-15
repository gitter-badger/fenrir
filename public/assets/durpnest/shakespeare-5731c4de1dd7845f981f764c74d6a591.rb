gziorninblat = ''
rand = Random.new

alpha = *('a'..'z')
beta = *(0..25)
gamma = Hash.new
beta.each do |num|
	gamma[num] = alpha[num-1]
end

pronouns = Regexp.new(("I|you|they|he|she|it"), Regexp::IGNORECASE)

actions_actor_single_past = Regexp.new(("sucked|rocked|ate|were eating|slew|saved"), Regexp::IGNORECASE)
actions_actor_single_present = Regexp.new(("are eating|are rocking|are sucking|are slaying|are saving"), Regexp::IGNORECASE)
actions = [actions_actor_single_past, actions_actor_single_present]

adjectives = Regexp.new(("large|small|red|ugly|pretty|serene"), Regexp::IGNORECASE)
nouns = Regexp.new(("dog|cat|mouse|mice|rat|house|forest"), Regexp::IGNORECASE)

gamma[26] = ' '
p gamma[19]

x = 0
solid = 0
until solid == 18
	rand = Random.new
	gziorninblat = gziorninblat + "#{gamma[rand(27)]}"
	gziorninblat = gziorninblat.sub(/  $/, ' ') + "#{gamma[rand(27)]}" while gziorninblat.match(/  $/)
	gziorninblat = gziorninblat.sub(/^([a-zA-Z\s]#{"{"+solid.to_s+"}"}).(.*)/, '\1\2') if gziorninblat.length > 18
	hunter = gziorninblat.match(/^(#{pronouns}) /)
	
	
	
	puts gziorninblat + " ::  #{x}"
	
	x+=1
end	
puts gziorninblat
puts x
