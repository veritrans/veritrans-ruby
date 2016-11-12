require 'excon'
require 'json'
require 'uri'

class Veritrans::TestingLib

  def initialize(server_url = "https://my.sandbox.veritrans.co.id:7676")
    @server_url = server_url
  end

  def logger
    @logger || Veritrans.logger
  end

  def logger=(value)
    @logger = value
  end

  def GET(url, options = {})
    logger.info("Veritrans::Testing GET #{url}")
    result = Excon.get(url)
    logger.info("Veritrans::Testing -> #{result.status}\n#{result.body}")
    options[:return_raw] ? result : result_json(result)
  end

  def POST(url, options = {})
    logger.info("Veritrans::Testing POST #{url} #{options[:body]}")
    result = Excon.post(url, options)
    logger.info("Veritrans::Testing -> #{result.status}\n#{result.body}")
    options[:return_raw] ? result : result_json(result)
  end

  def get_permata_va(va_number)
    GET(@server_url + "/api/permata_va/#{va_number}")
  end

  def pay_permata_va(va_number)
    POST(@server_url + "/api/permata_va/#{va_number}/pay")
  end

  def get_bca_va(va_number)
    GET(@server_url + "/api/bca_va/#{va_number}")
  end

  def pay_bca_va(va_number)
    POST(@server_url + "/api/bca_va/#{va_number}/pay")
  end

  def get_klik_bca(merchant_code, user_id)
    GET(@server_url + "/api/klikbca/#{merchant_code}/#{user_id}")
  end

  def pay_klik_bca(merchant_code, user_id, order_id = nil)
    POST(@server_url + "/api/klikbca/#{merchant_code}/#{user_id}/pay" + (order_id ? "?order_id=#{order_id}" : ''))
  end

  def get_mandiri_bill(bill_key)
    GET(@server_url + "/api/mandiri_bill/#{bill_key}")
  end

  def pay_mandiri_bill(bill_key)
    POST(@server_url + "/api/mandiri_bill/#{bill_key}/pay")
  end

  def get_indomaret(payment_code)
    GET(@server_url + "/api/indomaret/#{payment_code}")
  end

  def pay_indomaret(payment_code)
    POST(@server_url + "/api/indomaret/#{payment_code}/pay")
  end

  def get_cimb_clicks(redirect_url)
    gateway_result = GET(redirect_url, return_raw: true)

    form_result = extract_form(gateway_result.body)

    POST(form_result[:url].sub("cimb/clicks/index", "api/cimb/inquiry"),
      body: URI.encode_www_form(form_result[:fields].to_a),
      headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
    )
  end

  def pay_cimb_clicks(redirect_url, user_id = "testuser00")
    gateway_result = GET(redirect_url, return_raw: true)

    form_result = extract_form(gateway_result.body)

    form_result[:fields]["AccountId"] = user_id

    result = POST(form_result[:url].sub("cimb/clicks/index", "api/cimb/pay"),
      body: URI.encode_www_form(form_result[:fields].to_a),
      headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
    )

    result2 = POST(result['redirect_url'],
      body: URI.encode_www_form(result['redirect_params'].to_a),
      headers: {'Content-Type' => 'application/x-www-form-urlencoded'},
      return_raw: true
    )

    result
  end

  # experimental
  def pay_snap(snap_token, payment_type, transaction_params = {})
    #snap_data = GET("https://app.sandbox.veritrans.co.id/snap/v1/payment_pages/#{snap_token}")
    #snap_data = GET("https://app.sandbox.midtrans.com/snap/v1/transactions/#{snap_token}")

    result = POST("https://app.sandbox.midtrans.com/snap/v1/transactions/#{snap_token}/pay",
      body: JSON.pretty_generate({
        payment_type: payment_type
      }.merge(transaction_params)),
      headers: json_headers
    )

    result
  end

  def extract_form(html)
    form_html = html.match(/(<form.+<\/form>)/m)[1]
    form_url = form_html.match(/action="(.+?)"/)[1]
    form_method = form_html.match(/method="(.+?)"/)[1]
    fields = {}
    form_html.gsub(/<input(.+?)>/) do |token|
      key = (token.match(/name="(.+?)"/) || [])[1]
      value = (token.match(/value="(.+?)"/) || [])[1]
      fields[key] = value
    end

    return {
      method: form_method,
      url: form_url,
      fields: fields
    }
  end

  def result_json(result)
    JSON.parse(result.body)
  end

  def json_headers
    {
      'Content-Type' => 'application/json;charset=UTF-8',
      'Accept' => 'application/json, text/plain, */*'
    }
  end
end

class Veritrans
  Testing = Veritrans::TestingLib.new
end
