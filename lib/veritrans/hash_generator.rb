module Veritrans
  module HashGenerator
    def self.generate(merchant_id, settlement_method, order_id, amount)
      hash_compoonent = "#{Config::MERCHANT_HASH_KEY},#{merchant_id},#{settlement_method},#{order_id},#{amount}"
      hash_result = Digest::SHA512.hexdigest(hash_compoonent)
    end
  end
end
