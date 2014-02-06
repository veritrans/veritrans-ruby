# :nodoc:
module Veritrans

  # :nodoc:
  module HashGenerator
    # Generate hash using SHA-512.
    #
    # Parameters:
    # * <tt>[String]merchant_hash_key</tt> - Merchant Hash key    
    # * <tt>[String]merchant_id</tt> - Merchant ID  
    # * <tt>[String]settlement_method</tt> - '01' Credit Card
    # * <tt>[String]order_id</tt> 
    # * <tt>[String]amount</tt> 
    def self.generate(merchant_hash_key, merchant_id, order_id)
      return Digest::SHA512.hexdigest("#{merchant_hash_key},#{merchant_id},#{order_id}")
    end

  end
end
