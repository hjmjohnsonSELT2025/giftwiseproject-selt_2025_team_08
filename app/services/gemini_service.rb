require 'net/http'
require 'json'
require 'uri'

class GeminiService
  BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models'
  MODEL = 'gemini-2.5-flash'

  def initialize
    @api_key = ENV['GOOGLE_API_KEY'] || Rails.application.credentials.dig(:google_api_key)
    raise "GOOGLE_API_KEY not configured" unless @api_key.present?
  end

  def test_call(prompt)
    call_api(prompt)
  end

  def generate_multiple_ideas(prompt, num_ideas = 3)
    call_api(prompt)
  end

  private

  def call_api(prompt)
    url = URI("#{BASE_URL}/#{MODEL}:generateContent?key=#{@api_key}")
    
    request_body = {
      contents: {
        parts: [
          { text: prompt }
        ]
      }
    }

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = http.request(request)
    
    parse_response(response)
  rescue => e
    "Error calling Gemini API: #{e.message}"
  end

  def parse_response(response)
    if response.code == '200'
      data = JSON.parse(response.body)
      text = data.dig('candidates', 0, 'content', 'parts', 0, 'text')
      text || "No response received"
    else
      error_data = JSON.parse(response.body)
      error_msg = error_data.dig('error', 'message') || response.body
      "API Error (#{response.code}): #{error_msg}"
    end
  rescue JSON::ParserError => e
    "Error parsing response: #{e.message}"
  end
end
