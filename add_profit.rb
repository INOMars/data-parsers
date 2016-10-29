# encoding: Windows-1252

require 'nokogiri'
require 'pg'
require 'unicode_utils'

conn = PG.connect( dbname: 'samsheff' )

File.open(ARGV[0]).each_line do |l|
  l = l.scrub.split(";")
  conn.exec("SELECT id FROM companies WHERE inn = '#{l[5]}'") do |result|
    if result.first and not result.first.values_at('id')[0].nil?
      puts result.first.values_at('id')[0]
      conn.exec("UPDATE companies SET profit = #{l[117]}, revenue = #{l[82]} WHERE id = #{result.first.values_at('id')[0]}")
    end
  end  
end
