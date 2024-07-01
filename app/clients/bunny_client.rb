require "net/http"

class BunnyClient
  BASE_URI =  "https://video.bunnycdn.com"

  def initialize(library_id:, access_key:)
    @library_id, @access_key = library_id, access_key
  end

  def videos(page: 1, per_page: 100)
    get "/videos?itemsPerPage=#{per_page}&page=#{page}"
  end

  def get(path)
    http_request Net::HTTP::Get, "/library/#{@library_id}#{path}"
  end

  def post(path, body:)
    http_request Net::HTTP::Post, "/library/#{@library_id}#{path}", body: body
  end

  private

  def http_request(method, path, body: nil)
    uri = URI.parse("#{BASE_URI}#{path}")
    puts uri

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.is_a?(URI::HTTPS)

    request = method.new(uri)
    request["accept"] = "application/json"
    request["AccessKey"] = @access_key

    if request.is_a? Net::HTTP::Post
      request.body = body.to_json
      request["content-type"] = "application/json"
    end

    response = http.request(request)

    if response.is_a? Net::HTTPSuccess
      JSON.parse(response.body).with_indifferent_access
    else
      binding.irb
      raise StandardError, "Request failed."
    end
  end
end
