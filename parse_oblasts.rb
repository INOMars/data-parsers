require 'nokogiri'

file_content = File.open(ARGV[0]).read

doc = Nokogiri::XML(file_content)

doc.xpath("//СведМН").each do |region|
  puts region["КодРегион"]
end
