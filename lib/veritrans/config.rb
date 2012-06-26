module Veritrans
  module Config

    MERCHANT_ID       = "sample1"
    MERCHANT_HASH_KEY = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789012345678901"

    FINISH_PAYMENT_RETURN_URL   = "http://192.168.10.219"
    UNFINISH_PAYMENT_RETURN_URL = "http://192.168.10.219"
    ERROR_PAYMENT_RETURN_URL    = "http://192.168.10.219"
    
    SERVER_HOST          = 'http://192.168.10.250:80'
    # Configuration         http://192.168.10.250:80/web1/deviceCheck.action
    # REQUEST_KEY_URL    = "http://192.168.10.250:80/web1/confirm.action"
    REQUEST_KEY_URL      = "/web1/commodityRegist.action"
    PAYMENT_REDIRECT_URL = "/web1/deviceCheck.action"
    
    # Settlement method:
    SETTLEMENT_TYPE_CARD = "01"
    
    # Flag: Sales and Sales Credit, 0: only 1 credit. If not specified, 0
    CARD_CAPTURE_FLAG = "1"
  end
end
