class MidtransError < StandardError
  attr_reader :status
  alias_method :http_status_code, :status
  attr_reader :data
  alias_method :api_response, :data
  attr_reader :request_options
  alias_method :raw_http_client_data, :request_options

  def initialize(message, http_status_code = nil, api_response = nil, raw_http_client_data = nil)
    super(message)
    @status = http_status_code
    @data = api_response
    @request_options = raw_http_client_data
  end
end