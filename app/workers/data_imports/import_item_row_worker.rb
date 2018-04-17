module DataImports
  
  class ImportItemRowWorker  
    include Sidekiq::Worker
    include JobLogger

    def perform(row)
      puts "--------------> #{Item.find_by(number: row['number']).inspect}"
      if Item.find_by(number: row["number"]).nil?
        item = Item.new
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.number = row["number"]
      else
        item = Item.find_by(number: row["number"])
        id = item.id
        name = item.name
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        
        item.name = name
        item.number = row["number"]
        item.id = id
      end
      puts "-------------> #{item.inspect}"
      if item.default_price != row["default_price"]
        puts item.default_price
        puts row["default_price"]
        item.prices.new(_type: "Default", start_date: Date.today, price: row["default_price"].to_d)
        item.default_price.end_date = Date.today unless item.default_price.nil?
      end
      
      if item.item_vendor_prices.where(:vendor_id => 106).nil? or item.item_vendor_prices.where(:vendor_id => 106).order(:created_at).last&.price != row["cost_price"]
        item.item_vendor_prices.new(vendor_id: 106, price: row["cost_price"])
      end
      
      item.save!
      add_log "-----> #{item.inspect}"
    end
  
  end
  
end