module DataImports
  
  class ImportItemRowWorker  
    include Sidekiq::Worker
    include JobLogger

    def perform(row)
      add_log "#{Item.find_by(number: row["number"]).inspect}"
      if Item.find_by(number: row["number"]).nil?
        item = Item.new
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.number = row["number"]
      else
        item = Item.find_by(number: row["number"])
        id = item.id
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.number = row["number"]
        item.id = id
      end
      # item.price = row["price"]
      # item.cost_price = row["cost_price"]
      if item.default_price != row["default_price"]
        item.default_price.end_date = Date.today unless item.default_price.nil?
        item.prices.new(_type: "Default", start_date: Date.today, price: row["default_price"])
      end
      
      if item.item_vendor_prices.where(:vendor_id => 106).nil? or item.item_vendor_prices.where(:vendor_id => 106).order(:created_at).last&.price != row["cost_price"]
        item.item_vendor_prices.new(vendor_id: 106, price: row["cost_price"])
      end
      
      item.save
      add_log "-----> #{item.inspect}"
    end
  
  end
  
end