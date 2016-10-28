require 'nokogiri'
require "unicode_utils"
require 'pg'

conn = PG.connect( dbname: 'samsheff' )

file_content = File.open(ARGV[0]).read

doc = Nokogiri::XML(file_content)

doc.xpath("//СведМН").each do |region|
  street = region.css("НаселПункт")[0]
  conn.exec("SELECT id FROM regions WHERE type = '#{UnicodeUtils.downcase(region.css('Регион')[0]['Тип'])}' AND name = '#{UnicodeUtils.downcase(region.css('Регион')[0]['Наим'])}' AND oblast_code = '#{region["КодРегион"]}';") do |result|
    puts UnicodeUtils.downcase(street["Тип"]) + "," + UnicodeUtils.downcase(street["Наим"]) + "," + result.first.values_at('id')[0] if street
  end
end
