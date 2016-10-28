require 'nokogiri'
require 'pg'
require 'unicode_utils'

conn = PG.connect( dbname: 'samsheff' )

file_content = File.open(ARGV[0]).read

doc = Nokogiri::XML(file_content)

doc.xpath("//Документ").each do |document|
  begin
    company = {}
    company["doc_id"] = document["ИдДок"]
    company["title"] = document.css("ОргВклМСП")[0]["НаимОрг"] || "#{document.css("ИПВклМСП")[0].css("ФИОИП")["Фамилия"]} #{document.css("ИПВклМСП")[0].css("ФИОИП")["Имя"]} #{document.css("ИПВклМСП")[0].css("ФИОИП")["Отчество"]}"
    company["short_title"] = document.css("ОргВклМСП")[0]["НаимОргСокр"] || "#{document.css("ИПВклМСП")[0].css("ФИОИП")["Фамилия"]} #{document.css("ИПВклМСП")[0].css("ФИОИП")["Имя"]} #{document.css("ИПВклМСП")[0].css("ФИОИП")["Отчество"]}"
    company["inn"] = document.css("ОргВклМСП")[0]["ИННЮЛ"] || document.css("ИПВклМСП")[0].css("ФИОИП")["ИННФЛ"]
    company["company_type"] = document["ВидСубМСП"]

    conn.exec("SELECT id FROM regions WHERE type = '#{UnicodeUtils.downcase(document.css('Регион')[0]['Тип'])}' AND name = '#{UnicodeUtils.downcase(document.css('Регион')[0]['Наим'])}' AND oblast_code = '#{document.css('СведМН')[0]["КодРегион"]}';") do |result|
      company["region_id"] = result.first.values_at('id')[0]
      company["oblast_id"] = document.css('СведМН')[0]["КодРегион"]
    end

    conn.exec("SELECT id FROM streets WHERE type = '#{UnicodeUtils.downcase(document.css('НаселПункт')[0]['Тип'])}' AND name = '#{UnicodeUtils.downcase(document.css('НаселПункт')[0]['Наим'])}' AND region_id = '#{company["region_id"]}';") do |result|
      company["street_id"] = result.first.values_at('id')[0]
    end 

   company["activities"] = [] 
    document.css("СвОКВЭДДоп").each do |activity|
      conn.exec("SELECT id FROM activities WHERE code = '#{UnicodeUtils.downcase(activity["КодОКВЭД"])}'") do |result|
         company["activities"] << result.first.values_at('id')[0] 
      end
    end

    company["activities"] = company["activities"].to_s
    puts company.values.to_a.join('|').gsub(/[\"']/, '').gsub("[", '{').gsub("]", "}")
  rescue
  end
end
