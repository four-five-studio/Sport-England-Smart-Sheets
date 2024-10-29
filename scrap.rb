require 'dotenv'
require 'http'
require 'json'
Dotenv.load

# list all folders within the root folder

response = HTTP.auth("Bearer #{ENV['SMARTSHEET_ACCESS_TOKEN']}")
               .get("https://api.smartsheet.com/2.0/folders/#{ENV['SMARTSHEET_FOLDER_ID']}/folders")

data = JSON.parse(response.body.to_s)
folders = data['data']&.map { |folder| folder['name'] } || []

if folders.empty?
  puts "No folders found"
else
  folders.each { |folder| puts "- #{folder}" }
end

# find folder with name "Intelligent Health Limited"

folder_id = data['data']&.find { |folder| folder['name'] == 'Intelligent Health Limited' }&.dig('id')

if folder_id
  puts "Folder ID: #{folder_id}"
else
  puts "Folder not found"
end

# find sheet within folder that begins with the name "1a"
response = HTTP.auth("Bearer #{ENV['SMARTSHEET_ACCESS_TOKEN']}")
                .get("https://api.smartsheet.com/2.0/folders/#{folder_id}")

data = JSON.parse(response.body.to_s)

data['sheets'].map { |sheet| puts "- #{sheet['name']}" }

sheet_id = data['sheets'].find { |sheet| sheet['name'].start_with?('1a') }&.dig('id')

response = HTTP.auth("Bearer #{ENV['SMARTSHEET_ACCESS_TOKEN']}")
                .get("https://api.smartsheet.com/2.0/sheets/#{sheet_id}")

data = JSON.parse(response.body.to_s)

# print sheet data
data['rows'].each do |row|
  puts row['cells'].map { |cell| cell['value'] }.join("\t")
end
