class CatalogItemAttribute < ActiveRecord::Base
  auditable

  belongs_to :merchant_catalog_item
  belongs_to :catalog_attribute

  has_many :paired_attributes, class_name: "CatalogItemAttribute",
    foreign_key: "paired_id"
  belongs_to :paired, class_name: "CatalogItemAttribute"

  def as_json(options={})
    if paired_attributes.empty?
      {
        id: id, 
        name: catalog_attribute.name,
        swatch_color: catalog_attribute.swatch_color,
        swatch_text: catalog_attribute.swatch_text
      }
    else
      {
        id: id,
        item: merchant_catalog_item.title,
        name: catalog_attribute.name,
        price: price > 0 ? price : merchant_catalog_item.price,
        swatch_color: catalog_attribute.swatch_color,
        swatch_text: catalog_attribute.swatch_text,
        paired: paired_attributes.as_json
      }
    end
  end

end
