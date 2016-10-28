require 'nokogiri'
require "unicode_utils"

file_content = File.open(ARGV[0]).read

doc = Nokogiri::XML(file_content)

doc.xpath("//СведМН").each do |region|
  begin
  puts UnicodeUtils.downcase(region.css("Регион")[0]["Тип"]) + "," + UnicodeUtils.downcase(region.css("Регион")[0]["Наим"]) + "," + region["КодРегион"]
  rescue
  end
end
