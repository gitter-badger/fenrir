@input = ["MIS - felony", "mis - criminal", "mis - criminal", "theft - Shoplifting", "theft - buglary"]

def hash_tree_parser(hash)
  hash.each do |k, v|
    #reg = Regexp.new((k), Regexp::IGNORECASE)
    puts k
    @input.each do |ele|
      puts "string: #{ele}"
      puts "regex: #{k}"
      if ele.match(k)
        puts "#{ele} matches #{k}"
        if v.is_a?(Hash)
          hash_tree_parser(v)
        else
          puts "#{ele} => #{v}"
        end
      end
    end
  end
end

test_hash = {/\bmis(chief)?\b/i => {"\bfelony\b" => "felony mischief", "\bcriminal\b" => "criminal mischief"}, "\btheft\b" => {"shoplifting" => "shoplifing", "\bburglary\b" => "burglary"}}

hash_tree_parser(test_hash)
