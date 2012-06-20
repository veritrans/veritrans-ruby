module Veritrans
  module PostData
    HiddenParams =[
      :settlement_type, 
      :merchant_id, 
      :merchanthash
    ]
    RequiredParams =[
      :order_id, 
      :session_id, 
      :gross_amount,
      :card_capture_flag
    ]
    OptionalParams =[
      :previous_customer_flag,
      :customer_status,
      :email,
      :first_name,
      :last_name,
      :postal_code,
      :address1,
      :address2,
      :city,
      :country_code,
      :phone,
      :birthday,
      :sex, # 1:male, 2:female, 3:other
      :card_no,
      :card_exp_date, # mm/yy/format
      :card_holder_name,
      :card_number_of_installment,
      :settlement_sub_type, 
      :shop_name,
      :screen_title,
      :contents,
      :timelimit_of_payment,
      :timelimit_of_cancel,
      :lang_enable_flag,
      :lang
    ]
    Params = RequiredParams + OptionalParams
  end

  # Sample of Array of commodity
  # [
  #   {"COMMODITY_ID" => "123", "COMMODITY_UNIT" => "1", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "BUKU", "COMMODITY_NAME2" => "BOOK"},
  #   {"COMMODITY_ID" => "1243", "COMMODITY_UNIT" => "9", "COMMODITY_NUM" => "1", "COMMODITY_NAME1" => "BUKU Sembilan", "COMMODITY_NAME2" => "BOOK NINE"}
  # ]
end
