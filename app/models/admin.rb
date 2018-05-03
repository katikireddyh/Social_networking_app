class Admin < ActiveRecord::Base
  auditable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # NOT :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  validates :id, uniqueness: true

  SUPER_ADMIN_EMAIL = 'eric.choi@causemobile.com'
  
  def name
    "#{first_name} #{last_name}"
  end
  
end
