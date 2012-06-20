module Veritrans
  module HashGenerator
    def self.generate(merchant_id, settlement_method, order_id, amount)
      wow = "#{Config::MERCHANT_HASH_KEY},#{merchant_id},#{settlement_method},#{order_id},#{amount}"
      #p wow
      wiw = Digest::SHA512.hexdigest(wow)
      #p wiw
    end
  end
end
