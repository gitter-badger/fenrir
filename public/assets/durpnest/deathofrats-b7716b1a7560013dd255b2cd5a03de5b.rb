require_relative('../storycreator/targetfile.rb')
require_relative('../algorithms/gen6parser.rb');

array = [1,2,3,4,5,6,7,8,9,0];
output1 = 0
output2 = 0
y = 0
z = 0

while y < 5 do
  x=0
  
  durp1 = Time.now.to_i

  yogi1 = Time.now.to_i
  puts yogi1
  while x < 100
  logic = Gen6logic.new('../algorithms/gen6charges.tsv');
  logic.grow_tree;
  x=x+1
  end
  x = 0
  while x < 100 do
    array.each do
      
      
    end
    x=x+1
  end
  durp1 = Time.now.to_i
  puts yogi1
  puts durp1-yogi1
  
  thingy = '';
  puts "..."
  
  yogi2 = Time.now.to_i
  puts yogi2
  
  x = 0
  while x < 100 do
    while y < 100 do
      array.each do
        logic = Gen6logic.new('../algorithms/gen6charges.tsv');
        logic.grow_tree;
      end
      y=y+1
    end
    x=x+1
  end
  durp2 = Time.now.to_i
  puts yogi2
  puts durp2-yogi2
  
  puts "external: #{durp1-yogi1}  vs. internal: #{durp2-yogi2}"
  output1 = output1 + (durp1-yogi1)
  output2 = output2 + (durp2-yogi2) 
  y=y+1
end

puts "total external: #{output1}  vs. total internal: #{output2}"

