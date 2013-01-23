# :nodoc:
module Veritrans

  # hold information of "post data" need to pass when server need to get_keys
  module PostData

    # +:merchant_id,+
    # +:merchant_url,+
    # +:session_id,+
    # +:finish_payment_return_url,+
    # +:unfinish_payment_return_url,+
    # +:error_payment_return_url
    Merchant =[
      :merchant_id, 
      :merchant_url, 
      :finish_payment_return_url,
      :unfinish_payment_return_url,
      :error_payment_return_url
    ]

    # +:settlement_type,+
    # +:gross_amount,+
    # +:card_no,+
    # +:card_exp_date,+
    # +:customer_id,+
    # +:previous_customer_flag,+
    # +:customer_status,+
    Payment =[
      :settlement_type, 
      :gross_amount,
      :card_no,
      :card_exp_date, # mm/yy
      :customer_id,
      :previous_customer_flag,
      :customer_status,
    ]

    # +:first_name,+
    # +:last_name,+
    # +:address1,+
    # +:address2,+
    # +:city,+
    # +:country_code,+
    # +:postal_code,+
    # +:phone,+
    # +:email,+
    # customer_specification_flag,
    Personal =[
      :first_name,
      :last_name,
      :address1,
      :address2,
      :city,
      :country_code,
      :postal_code,
      :phone,
      :email,
      :customer_specification_flag # billing_address_different_with_shipping_address
    ]

    # +:shipping_flag,
    # +:shipping_first_name,
    # +:shipping_last_name,
    # +:shipping_address1,
    # +:shipping_address2,
    # +:shipping_city,
    # +:shipping_country_code,
    # +:shipping_postal_code,
    # +:shipping_phone,
    # +:shipping_method,
    Shipping =[
      :shipping_flag, # required_shipping_address
      :shipping_first_name,
      :shipping_last_name,
      :shipping_address1,
      :shipping_address2,
      :shipping_city,
      :shipping_country_code,
      :shipping_postal_code,
      :shipping_phone,
      :shipping_method
    ]

    # +:lang_enable_flag,+
    # +:lang+
    Language =[
      :lang_enable_flag,
      :lang
    ]

    # +:repeat_line,+
    # +:purchases,+
    Purchases =[
      :repeat_line,
      :purchases
    ]

    # +:commodity_id,+
    # +:commodity_unit,+
    # +:commodity_num,+
    # +:commodity_name1,+
    # +:commodity_name2+ 
    PurchaseParam =[
      :commodity_id,
      :commodity_unit, # commodity_qty
      :commodity_num,  # commodity_price
      :commodity_name1,
      :commodity_name2 
    ]

    # AliasesParam = {
    #     :commodity_unit => :commodity_qty,
    #     :commodity_num  => :commodity_price
    # }

    # +:order_id,+
    # +:session_id,+
    # +:merchanthash,+
    # +:card_capture_flag+
    OtherParam =[
      :order_id, 
      :session_id, 
      :merchanthash,
      :card_capture_flag,
      :promo_id
    ]

    # +:merchant_id,+ 
    # +:merchanthash,+
    # +:finish_payment_return_url,+
    # +:unfinish_payment_return_url,+
    # +:error_payment_return_url+
    ServerParam =[
      :merchant_id, 
      :merchanthash,
      :finish_payment_return_url,
      :unfinish_payment_return_url,
      :error_payment_return_url
    ]

    # Params are the combination of this group:
    PostParam = (Merchant + Payment + Personal + Shipping + Language + Purchases + OtherParam) - ServerParam
  end

  # Sample of Array of purchase commodity
  # [
  #   {"COMMODITY_ID" => "1233", "COMMODITY_UNIT" => "1", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "BUKU",          "COMMODITY_NAME2" => "BOOK"},
  #   {"COMMODITY_ID" => "1243", "COMMODITY_UNIT" => "9", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "BUKU Sembilan", "COMMODITY_NAME2" => "BOOK NINE"}
  # ]
end
