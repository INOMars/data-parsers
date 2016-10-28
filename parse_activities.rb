require 'nokogiri'
require "unicode_utils"

file_content = File.open(ARGV[0]).read

doc = Nokogiri::XML(file_content)

doc.xpath("//СвОКВЭДДоп").each do |activity|
  begin
  puts UnicodeUtils.downcase(activity["КодОКВЭД"]) + "|" + UnicodeUtils.downcase(activity["НаимОКВЭД"])
  rescue
  end
end

