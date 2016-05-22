class Item < ActiveRecord::Base
  
  searchable do
    text :description, :stored => true
    text :number, :stored => true
    text :name, :stored => true
    text :slug, :stored => true
    text :category do
      category.name if category
    end
    text :brand do
      brand.name if brand
    end
    text :item_properties do
      item_properties.map { |item_propertie| item_propertie.key }
    end

    text :item_properties do
      item_properties.map { |item_propertie| item_propertie.value }
    end
  end

  scope :active, -> { where(:active => true)}
  
  has_many :account_item_prices, :dependent => :destroy, :inverse_of => :item
  has_many :group_item_prices, :dependent => :destroy, :inverse_of => :item
  has_many :item_vendor_prices
  has_many :images
  # has_attached_file :image, styles: {
  #   thumb: '100x100>',
  #   square: '200x200#',
  #   medium: '400x400>'
  # }
  
  has_many :order_line_items
  has_many :item_properties
  has_many :item_categories
  has_many :categories, :through => :item_categories
  belongs_to :category
  belongs_to :brand
  belongs_to :model
  attr_reader :category_tokens
  
  validates_uniqueness_of :number
  # validates_uniqueness_of :slug
  
  before_validation :slugger
  
  def brand_name
    brand.try(:name)
  end
  
  def brand_name=(name)
    self.brand = Brand.find_by(:name => name) if name.present?
  end
  
  def category_name
    category.try(:name)
  end
  
  def category_name=(name)
    self.category = Category.find_by(:name => name) if name.present?
  end
  
  def category_tokens=(tokens)
    self.category_ids = tokens.split(",")
  end
  
  def self.lookup(word)
    includes(:brand, :categories).where("lower(number) like ? or lower(items.name) like ? or lower(items.description) like ? or lower(brands.name) like ? or lower(categories.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:brand, :categories)
    # word = word.downcase.gsub(/[^a-z 0-9]/, " ")
    # if ransack(:number_cont_all => word.split).result.count > 1
    #   ransack(:number_cont_all => word.split).result
    # elsif ransack(:number_or_name_cont_all => word.split).result.count > 1
    #   ransack(:number_or_name_cont_all => word.split, :name_cont_all => word.split).result
    # elsif ransack(:number_or_name_or_description_cont_all => word.split).result.count > 1
    #   ransack(:number_or_name_or_description_cont_all => word.split).result
    # elsif ransack(:number_or_name_or_description_or_categories_name_cont_all => word.split).result.count > 1
    #   ransack(:number_or_name_or_description_or_categories_name_cont_all => word.split).result
    # else
    #   ransack(:number_or_name_or_description_or_categories_name_cont_all => word.split).result
    # end  
  end
  
  
  def self.search_fulltext(word, page)
    # includes(:brand, :categories).where("lower(number) like ? or lower(items.name) like ? or lower(items.description) like ? or lower(brands.name) like ? or lower(categories.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:brand, :categories)
    # Item.search { fulltext word }.result
    res = Sunspot.search( Item ) do
       fulltext word
       paginate :page => page, :per_page => 10
    end
    res.results
  end

  def self.render_auto(word)
    res = Sunspot.search( Item ) do
       fulltext word
    end
    
    occurence = []
    res.results.each do |item|
      occurence << item.name if item.name.include?(word)
      occurence << item.description if item.description.include?(word)
      occurence << item.number if item.number.include?(word)
      occurence << item.slug if item.slug.include?(word)
      occurence << item.category.name if item.category and item.category.name.include?(word)
      occurence << item.brand.name if item.brand and item.brand.name.include?(word)
    end
    occurence.uniq
  end
  
  self.per_page = 10
  
  def actual_price(account_id={})
    unless account_id.blank?
      unless get_lowest_price(account_id).blank?
        return [get_lowest_price(account_id), get_lowest_public_price].min
      else
        return get_lowest_public_price
      end
      return get_lowest_public_price
    end
  end
  
  def get_lowest_public_price
    prices_array = []
    if sale_price.to_f > 0
      prices_array << sale_price.to_f
    end
    prices_array << price
    price = prices_array.min
    return price == 0 ? false : price
  end
  
  def get_lowest_price(account_id)
    acct_price = get_account_price(account_id).to_f
    group_price = get_group_price(account_id).to_f
    prices_array = []
    if acct_price > 0
      prices_array << acct_price
    end
    if group_price > 0
      prices_array << group_price
    end
    puts "PRICES ARRAY #{prices_array.inspect}"
    price = prices_array.min
    return price == 0 ? false : price
  end
  
  def get_account_price(account_id)
    if has_account_price(account_id)
      self.account_item_prices.by_account(account_id).last.price
    end
  end
  
  def get_group_price(account_id)
    group_id = Account.find(account_id).group_id
    if has_group_price(group_id)
      self.group_item_prices.by_group(group_id).last.price
    end
  end
  
  def has_account_price(account_id)
    return !self.account_item_prices.by_account(account_id).blank? 
  end
  
  def has_group_price(group_id)
    return !self.group_item_prices.by_group(group_id).blank? 
  end
  
  def default_image_path
    unless images.first.nil?
      puts "----> #{images.first.path}"
      images.first.path
    end
  end
  
  def slugger
    puts "we slugging it out"
    if self.slug.nil?
      puts "NO SLUG"
      self.slug = name.downcase.tr(" ", "-") unless self.name.nil?
      puts "---> #{self.inspect}"
    else
      puts "---> #{self.slug}"
    end
  end
  
  def times_purchased
    # total = 0.0
    # OrderLineItem.joins(:item).where(:item_id => id).each {|o| total += o.quantity.to_i}
    # total
    OrderLineItem.where(item_id: id).sum(:quantity)
  end
  
  def self.times_ordered
    Item.joins(:order_line_items).group(:item_id).sort_by(&:times_purchased).reverse!
    # Item.select("items.*, count(order_line_items.quantity) AS times_purchased")
    # .joins("INNER JOIN order_line_items ON order_line_items.quantiy = docs.sourceid")
    #  .group("docs.id")
    # .order("denotations_count DESC")
  end
  
  def import_xml_new
    current_item_id = self.id
    begin
      noko = File.open("#{Rails.root}/app/assets/images/ecdb.individual_items/#{self.number}.xml") { |f| Nokogiri::XML(f) }
    rescue
      puts "No such file #{self.number}.xml"
    else
      # noko.xpath("//oa:Specification//oa:Property//oa:NameValue").each_with_index do |k,v, index|  
      #   ItemProperty.create(:item_id => self.id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
      # end
      
      
      noko.xpath("//us:Matchbook").each_with_index do |k, index|  
        # ItemProperty.create(:item_id => self.id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
        rel_make    = noko.xpath("//us:Matchbook")[index].element_children[0].element_children[0].text
        rel_family  = noko.xpath("//us:Matchbook")[index].element_children[2].text
        rel_model   = noko.xpath("//us:Matchbook")[index].element_children[3].text
        
        cat = Category.find_by(:slug => "inks-toners")
        
        make_slug = rel_make.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        make = Category.find_or_create_by(:name => rel_make, :parent_id => cat.id, :slug => make_slug)
        
        family_slug = rel_family.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        family = Category.find_or_create_by(:name => rel_family, :parent_id => make.id, :slug => family_slug)
        
        model_slug = rel_model.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        imodel = Category.find_or_create_by(:name => rel_model, :parent_id => family.id, :slug => model_slug)
        
        ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => imodel.id)
        
      end
      
      #(0..(noko.xpath("//us:Matchbook").count)-1).each {|i| puts noko.xpath("//us:Matchbook//us:Device")[i] }
          # 
          #   brand = Brand.find_by(:prefix => noko.css("[agencyRole=Prefix_Number]").text.gsub(/\s+/, ""))
          #   brand = brand.id unless brand.nil?
          #   
          #   noko.css("[listName=HierarchyLevel1]").each do |cat1|
          #     cat1_slug = cat1.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
          #     Category.find_or_create_by(:name => cat1.text, slug: cat1_slug)
          #   end
          #   
          #   noko.css("[listName=HierarchyLevel2]").each_with_index do |cat2, index|
          #     cat1 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel1]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
          #     cat2_slug = cat2.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
          #     Category.find_or_create_by(name: cat2.text, slug: cat2_slug, parent_id: cat1.id)
          #   end
          #   
          #   noko.css("[listName=HierarchyLevel3]").each_with_index do |cat3, index|
          #     cat2 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel2]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
          #     cat3_slug = cat3.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
          #     cat3 = Category.find_or_create_by(name: cat3.text, slug: cat3_slug, parent_id: cat2.id)
          #     puts "-------------------------------------> #{current_item_id}"
          #     ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => cat3.id)
          #   end
          #   
          #   height = noko.xpath("//us:Packaging//us:Dimensions//oa:HeightMeasure").text
          #   width = noko.xpath("//us:Packaging//us:Dimensions//oa:WidthMeasure").text
          #   length = noko.xpath("//us:Packaging//us:Dimensions//oa:LengthMeasure").text
          #   wieght = noko.xpath("//us:Packaging//us:Dimensions//us:WeightMeasure").text
          #   
          #   name = noko.css("[type=Long_Item_Description]").text
          #   description = noko.css("[type=Item_Consolidated_Copy]").text
          #   
          #   
          #   update_attributes(:brand_id => brand, :slug => self.number.downcase, :height => height, :width => width, :length => length, :weight => weight, :name => name, :description => description)
          # 
          #   bucket_name = '247officesuppy/400/400'
          #   s3 = AWS::S3.new()
          #   bucket = s3.buckets[bucket_name]
          #   
          #   
          #   sku_group_image = noko.xpath("//us:SkuGroupImage").text
          #   single_image = noko.xpath("//oa:DrawingAttachment//oa:FileName").text
          #   
          #   if AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{single_image}"].exists?
          #     image = single_image
          #     puts "----> SINGLE IMAGE = #{image}"
          #     bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
          #   elsif AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{sku_group_image}"].exists?
          #     image = sku_group_image
          #     puts "----> SKU GROUP IMAGE = #{image}"
          #     bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
          #   else
          #     image = nil
          #   end
          #   
          #   if image
          #     item_images = self.images
          #   
          #     if self.images.count > 1
          #       (1..self.images.count).each {|im| Image.find_by(id: self.images[im].id).destroy }
          #     end
          #   
          #     if self.images.count == 1
          #       Image.find_by(id: self.images.first.id).update_attributes(:attachment_file_name => image)
          #     else
          #       Image.create(:attachment_file_name => image)
          #     end
          #   end
          #   
          end
    
  end
  
  # def import_xml
  #     AWS.config({
  #         :access_key_id => "#{SECRET['AWS']['ACCESS_KEY_ID']}",
  #         :secret_access_key => "#{SECRET['AWS']['SECRET_ACCESS_KEY']}",
  #     })
  #     bucket_name = '247officesuppy/400/400'
  # 
  #     s3 = AWS::S3.new()
  #     bucket = s3.buckets[bucket_name]
  #     
  #     begin
  #       noko = Hash.from_xml(open("#{Rails.root}/app/assets/images/ecdb.individual_items/#{self.number}.xml"))
  #     rescue
  #       "No such file #{self.number}.xml"
  #     else
  #       info = noko["SyncItemMaster"]["DataArea"]["ItemMaster"]["ItemMasterHeader"]
  #       brand = info["ManufacturerItemID"]["schemeAgencyName"]
  #       
  #       sku_group_image = ""
  #       info["Classification"].each {|o| if o["type"] == "SKU_Group" then sku_group_image = o["SkuGroupImage"] end }
  #       single_image = info['DrawingAttachment']['FileName']
  #       
  #       if AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{single_image}"].exists?
  #         
  #         image = single_image
  #         puts "----> SINGLE IMAGE = #{image}"
  #         bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
  #         
  #       elsif AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{sku_group_image}"].exists?
  #         
  #         image = sku_group_image
  #         puts "----> SKU GROUP IMAGE = #{image}"
  #         bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
  #         
  #       else
  #         image = "NOA.JPG"
  #       end
  #       
  #       item_images = self.images
  #       
  #       if self.images.count > 1
  #         (1..self.images.count).each {|im| Image.find_by(id: "im").destroy }
  #       end
  #       
  #       if self.images.count == 1
  #         Image.find_by(id: self.images.first.id).update_attributes(:attachment_file_name => image)
  #       else
  #         Image.create(:attachment_file_name => image)
  #       end
  #       
  #     end
  #   end
  
end