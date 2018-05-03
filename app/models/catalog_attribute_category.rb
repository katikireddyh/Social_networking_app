class CatalogAttributeCategory < ActiveRecord::Base
  auditable

  has_many :catalog_attributes
end
