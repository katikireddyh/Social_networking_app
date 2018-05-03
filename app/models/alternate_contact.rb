class AlternateContact < ActiveRecord::Base
  belongs_to :consumer
  validates :consumer_id, presence: true
  validates :contact_type, presence: true
  validates :contact_data, presence: true
  #validates :contact_data, uniqueness: true, scope: :contact_data
  validate :contact_data, :check_consumer
  
  def self.search_for(attrib,data)
      scope = self.where("contact_type = ? AND contact_data ILIKE ?", attrib, data.to_s.downcase) #case insensitive
      if scope.any?
        return scope
      end
  end
  
  def check_consumer
    if self.contact_type == "email"
      c = Consumer.search_for(:email, self.contact_data)
      c.present? ? (self.errors.add :email, 'is already taken') : true
    end
  end
  
end
