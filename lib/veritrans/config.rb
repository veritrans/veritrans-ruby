# :nodoc:
module Veritrans

  # hold constants configuration define in server merchant
  module Config

    # Merchant ID - defined from veritrans
    MERCHANT_ID       = "sample3"

    # Merchant Hash Key - defined from veritrans
    MERCHANT_HASH_KEY = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789012345678901"

    # Finish return url (no error / sucees) - define by merchant
    FINISH_PAYMENT_RETURN_URL   = "http://192.168.10.219/"

    # Unfinish return url - define by merchant
    UNFINISH_PAYMENT_RETURN_URL = "http://192.168.10.219/"

    # Error return url - define by merchant
    ERROR_PAYMENT_RETURN_URL    = "http://192.168.10.219/"
    
    # server Veritrans - defined in gem - no change!
    SERVER_HOST          = 'http://192.168.10.250:80'
    # Configuration         http://192.168.10.250:80/web1/deviceCheck.action
    # REQUEST_KEY_URL    = "http://192.168.10.250:80/web1/confirm.action"

    # Request Key Url - use in #get_keys - defined in gem - no change!
    REQUEST_KEY_URL      = "/web1/commodityRegist.action"

    # Payment Redirect Url - defined in gem - no change!
    PAYMENT_REDIRECT_URL = "/web1/deviceCheck.action"
    
    # Default Settlement method:
    SETTLEMENT_TYPE_CARD = "01"
    
    # Flag: Sales and Sales Credit, 0: only 1 credit. If not specified, 0
    CARD_CAPTURE_FLAG = "1"
  end
end
