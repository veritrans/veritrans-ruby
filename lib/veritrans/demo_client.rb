module Veritrans

  # :nodoc:
  class DemoClient < Client 
    include DemoData

    # :nodoc:
    def get_keys
      init_order_info
      # init_checkout_info
      # init_card_info
      # init_shipping
      ini_commodity 
      super
    end
  end
end