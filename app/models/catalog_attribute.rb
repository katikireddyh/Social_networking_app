class CatalogAttribute < ActiveRecord::Base
  auditable

  belongs_to :catalog_attribute_category
  has_many :catalog_item_attributes
  has_many :merchant_catalog_items, through: :catalog_item_attributes
end
