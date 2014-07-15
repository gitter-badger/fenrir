File.open('gen7building_permits.txt', 'r') do |nsfile|
  File.open('gen7building_permits.tsv', 'w') do |lokifile|

    nsfile.each do |inline|
      inline = inline.chomp
      inline = inline.gsub(/\s{4}/, "\t")
      lokifile.puts inline
    end
  end
end
