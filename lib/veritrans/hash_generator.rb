# :nodoc:
module Veritrans

  # :nodoc:
  module HashGenerator

    # Generate hash using SHA-512.
    #
    # Parameters:
    # * <tt>[String]merchant_id</tt> - Merchant ID
    # * <tt>[String]merchant_hash_key</tt> - Merchant Hash key
    # * <tt>[String]settlement_method</tt> - '01' Credit Card
    # * <tt>[String]order_id</tt> 
    # * <tt>[String]amount</tt> 
    def self.generate(merchant_id, merchant_hash_key, settlement_method, order_id, amount)
      Digest::SHA512.hexdigest("#{merchant_hash_key},#{merchant_id},#{settlement_method},#{order_id},#{amount}")
    end
  end
end
