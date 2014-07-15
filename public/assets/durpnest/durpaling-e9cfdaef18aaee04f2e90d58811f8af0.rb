x=0
time1 = Time.now

def derpaling(x, time1)
  x += 1
  puts "derpaling: #{x}"
  while Time.now - time1 < 0.05
    derpaling(x, time1)
  end
end

derpaling(x, time1)
