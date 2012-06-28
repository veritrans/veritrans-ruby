# :nodoc:
module Veritrans

  # :nodoc:
  module HashGenerator

    # Generate hash using SHA-512, it need a Config::MERCHANT_HASH_KEY.
    #
    # Parameters:
    # * <tt>[String]merchant_id</tt> - Merchant ID
    # * <tt>[String]settlement_method</tt> - '01' Credit Card
    # * <tt>[String]order_id</tt> 
    # * <tt>[String]amount</tt> 
    def self.generate(merchant_id, settlement_method, order_id, amount)
      hash_compoonent = "#{Config::MERCHANT_HASH_KEY},#{merchant_id},#{settlement_method},#{order_id},#{amount}"
      hash_result = Digest::SHA512.hexdigest(hash_compoonent)
    end
  end
end
