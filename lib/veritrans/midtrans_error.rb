class MidtransError < StandardError
  attr_reader :status
  attr_reader :data

  def initialize(message, status_code = nil, api_response = nil)
    super(message)
    @status = status_code
    @data = api_response
  end
end