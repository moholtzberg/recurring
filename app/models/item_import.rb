class ItemImport
  # switch to ActiveModel::Model in Rails 4
  include ActiveModel::Model

  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_products.map(&:valid?).all?
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      unless Item.find_by(:number => row["number"])
        product = Item.new
        product.attributes = row.to_hash.slice(*Item.attribute_names())
        puts "#{i}----> #{product.valid?}"
      else
        product = Item.find_by(:number => row["number"])
        id = product.id
        product.attributes = row.to_hash.slice(*Item.attribute_names())
        product.id = id
        puts "#{i}----> #{product.valid?}"
        puts "y----> #{product.inspect}"
        # product.slug = product.number
        #puts "#{i}----> #{product.inspect}"
      end
      product
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Spreadsheet.open(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end