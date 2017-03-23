# Gets WHOIS results from JSON WHOIS

require 'unirest'
require 'csv'
require 'dotenv/load'

# Token from jsonwhois.com
api_token = ENV["TOKEN"] 

if ARGV.size < 1
  puts "USAGE: TOKEN=<json_API_token> ruby unirestapi.rb <input_csv> <output_csv>"
  puts "DESCRIPTION: Fetches registrant, admin and tech contacts from jsonwhois.com based on\n
                     <input_csv> which expects one domain name per line"
  exit
end

input_filename = ARGV[0] || "sample.txt"
output_filename = ARGV[1] || "output.txt"

puts "Starting"
CSV.open(output_filename, "wb") do |csv|
  puts "Output file=#{output_filename}"
  File.open(input_filename).each do |line|
    domain = line.split(",").first.strip
    puts "fetching #{domain}"
    response = Unirest.get("http://jsonwhois.com/api/v1/whois", 
                          headers:{ 
                            "Accept" => "application/json", 
                            "Authorization" => "Token token=#{api_token}"
                          },
                          parameters:{ :domain => domain }
                        )

    # response.code # Status code
    # response.headers # Response headers
    body = response.body # Parsed body
    # response.raw_body # Unparsed body
    registrant = body["registrant_contacts"]
    if registrant.nil? || registrant.empty?
      registrant_name = nil
      registrant_email = nil
      puts response.raw_body
    else
      registrant_name = registrant[0]["name"]
      registrant_email = registrant[0]["email"]
    end

    admin = body["admin_contacts"]
    if admin.nil? || admin.empty?
      admin_name = nil
      admin_email = nil
    else
      admin_name = admin[0]["name"]
      admin_email = admin[0]["email"]
    end

    tech = body["technical_contacts"]
    if tech.nil? || tech.empty?
      tech_name = nil
      tech_email = nil
    else
      tech_name = tech[0]["name"]
      tech_email = tech[0]["email"]
    end

    result = [domain, registrant_name, registrant_email, admin_name, admin_email, tech_name, tech_email]
    csv << result 
    csv.flush
  end
end
