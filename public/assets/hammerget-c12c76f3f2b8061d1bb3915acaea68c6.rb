
require_relative('Lowki.rb')

work = Targetfile.new(File.open('/home/mamanbrigitte/cms_stories_with_types.tsv', 'r'))
work.get_headers
puts work.headers
