# Ruby parser, but whois black lists

require 'whois-parser'
require 'csv'

if ARGV.size < 2
  puts "USAGE: getwhois input_filename [output_filename] "
  exit
end

input_filename = ARGV[0] || "file.txt"
output_filename = ARGV[1] || "output.txt"

puts "Using input file=#{input_filename}, output file=#{output_filename}"

client = Whois::Client.new
CSV.open(output_filename, "w") do |csv|
  puts "Fetching:"
  File.open(input_filename, "r").each do |line|
    domain = line.strip
    puts "... '#{domain}'"
    record = client.lookup(domain)
    parser = record.parser

    # data
    contacts = {}
    contacts[:registrant_name] = parser.try(:registrant_contacts).try(:name) rescue nil
    contacts[:registrant_email] = parser.try(:registrant_contacts).try(:email) rescue nil
    contacts[:admin_name] = parser.try(:admin_contacts).try(:name) rescue nil
    contacts[:admin_email] = parser.try(:admin_contacts).try(:email) rescue nil
    contacts[:tech_name] = parser.try(:tech_contacts).try(:name) rescue nil
    contacts[:tech_email] = parser.try(:tech_contacts).try(:email) rescue nil

    result = [
      parser.domain, 
      parser.domain_id,
      contacts[:registrant_name],
      contacts[:registrant_email],
      contacts[:admin_name],
      contacts[:admin_email],
      contacts[:tech_name],
      contacts[:tech_email]
    ]

    puts result.join(", ")

    csv << result
  end
end

puts "Done"

