require 'net/http'
require 'uri'
require 'json'

def read_env_file(file_path)
  env_vars = {}
  File.foreach(file_path) do |line|
    next if line.strip.empty? || line.start_with?('#')
    key, value = line.split('=', 2)
    env_vars[key.strip] = value.strip.gsub(/["']/, '')
  end
  env_vars
end

def get_jwt_token(env_vars)
  uri = URI("#{env_vars['COMMON_LOGIN_URL']}/login")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme == 'https'

  auth_payload = {
    email: env_vars['COMMON_LOGIN_EMAIL'],
    password: env_vars['COMMON_LOGIN_PASSWORD']
  }

  request = Net::HTTP::Post.new(uri.request_uri)
  request['Content-Type'] = 'application/json'
  request['Accept'] = 'application/json'
  request.body = auth_payload.to_json

  begin
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      return JSON.parse(response.body)['token']
    else
      puts "Authentication failed. Status code: #{response.code}"
      puts response.body
      return nil
    end
  rescue StandardError => e
    puts "An error occurred during authentication: #{e.message}"
    return nil
  end
end

def get_company_data(company_id, jwt_token)
  uri = URI("https://api-sandbox.acubeapi.com/verify/company/#{company_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  request['Authorization'] = "Bearer #{jwt_token}"
  request['Accept'] = 'application/json'

  begin
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      return JSON.parse(response.body)
    else
      puts "Company verification failed. Status code: #{response.code}"
      puts response.body
      return nil
    end
  rescue StandardError => e
    puts "An error occurred during company verification: #{e.message}"
    return nil
  end
end

# Main execution
env_vars = read_env_file('.env.local')

unless ARGV.size == 1
  puts "Usage: ruby script.rb <company_id>"
  exit 1
end

company_id = ARGV[0]

jwt_token = get_jwt_token(env_vars)

if jwt_token
  puts "Authentication successful. Received JWT token."

  company_data = get_company_data(company_id, jwt_token)

  if company_data
    puts "Company verification successful."
    pretty_json = JSON.pretty_generate(company_data)
    puts pretty_json
  end
else
  puts "Failed to obtain JWT token. Exiting..."
end
