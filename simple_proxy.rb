require 'sinatra'
require 'net/http'
require 'uri'

set :bind, '0.0.0.0'
set :port, 1030

NSLOOKUP_COMMAND = "nslookup %s | awk -F': ' 'NR==6 { print $2 } '"

get '/*' do
  ip = `#{NSLOOKUP_COMMAND % request.host}`.strip
  url = "http://#{request.host}#{request.path_info}"
  uri = URI.parse(url)

  http = Net::HTTP.new(ip, uri.port)
  http_request = Net::HTTP::Get.new(uri.request_uri)
  http_request['Host'] = request.host
  http_response = http.request(http_request)

  response_headers = {}

  http_response.each_header do |h|
    response_headers[h] = http_response[h]
  end

  puts response_headers

  status http_response.code
  headers response_headers
  body http_response.body
end