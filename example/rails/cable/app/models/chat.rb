class Chat < ApplicationRecord
  belongs_to :sender, class_name: User
  after_create_commit { ChatBroadcasterJob.perform_later(self) }

  ITEMABLE_REGEX = /\A.*jual\s+/i

  def itemable?
    !(text =~ ITEMABLE_REGEX).nil?
  end

  def gross_amount
    items.inject(0) { |sum, elem| sum + elem[:price] }
  end

  def items
    items = []
    return items unless itemable?

    clean_text = text.dup.gsub(ITEMABLE_REGEX, '')

    # satu text jualan bisa berisi banyak item yang dipisahkan
    # oleh tanda titik koma (;)
    items_texts = clean_text.split(';')

    # iterasi tiap text item
    items_texts.each do |item_text|
      # pisahkan item text berdasarkan tanda koma
      # setelah itu ambil tiap 2 elemen data tiap satu iterasi
      item_text.split(",").each_slice(2) do |name, price|
        # tambahkan ke koleksi items
        items << {
          name: name,
          price: price.try(:tr, '.', '').to_i
        }
      end
    end

    # return items
    items
  end
end
