class SkuGroup < ActiveRecord::Base
  has_many :items
  validates :name, presence: true

  def self.lookup(term)
    where('lower(name) like (?)', "%#{term.downcase}%")
  end
end
