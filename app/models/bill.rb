class Bill < ActiveRecord::Base
  belongs_to :merchant
  has_many :transactions
  
  self.per_page = 20
  paginates_per 20

  default_scope { order(created_at: :desc) }

  validates :merchant, presence: true
  validates :title, uniqueness: {scope: :merchant}, presence: true
  validate :has_qr_code

  phony_normalize :consumer_phone, default_country_code: 'US'
  validates :consumer_phone, phony_plausible: true

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  validate :disables_tipping_for_user_defined_transactions

  attr_accessor :expiration_date
  attr_accessor :setting_customer_entered_amount

  def completed_transactions
    transactions.where('consumer_id IS NOT null')
  end

  def disables_tipping_for_user_defined_transactions
    self.tipping_enabled = false if amount.nil?
  end

  def active?
    if reusable
      !expired?
    else
      !paid? and !expired?
    end
  end
  
  def allow_tipping #to fix checkout
    false
  end

  def paid_transactions
    transactions.where("state != 'created'")
  end

  def paid_bywallet
    wallet_transactions.where("status = 'Success'")
  end

  def used?
    !reusable and paid?
  end

  def paid?
    paid_transactions.count + paid_bywallet.count > 0
  end
  
  def paid_in_full?
    if paid_amount >= self.amount
      return true
    else
      return false
    end
  end
  
  def paid_amount
    return ActiveRecord::Base.connection.execute("SELECT * FROM paid_on_bill(#{self.id});").values.first.first.to_f
  end
  
  def unpaid_balance
    if self.amount
      return (self.amount - paid_amount).to_f
    else
      return nil
    end
  end

  def unpaid?
    !paid?
  end

  def expired?
    return false unless expires_at
    expired_in_pacific_time?
  end
  
  def self.overpaid
    res = []
    Bill.all.each do |bill|
      if bill.amount && bill.paid_amount > bill.amount
        res << bill
      end
    end
    return res
  end

  def status
    if active?
      'Active'
    else
      if used?
        'Used'
      elsif expired?
        'Expired'
      else
        'Used'
      end
    end
  end

  def has_qr_code
    self.qr_code = generate_qr_code if qr_code.blank?
  end

  def generate_qr_code
    loop do
      code = Devise.friendly_token
      unless Bill.where(qr_code: code).first
        unless qr_code.blank?
          code = qr_code
        end
      

        data = StringIO.new(qr_data)
        data.class_eval do
          attr_accessor :content_type, :original_filename
        end
        data.content_type = 'image/png'
        data.original_filename = 'qr_code.png'

        self.image = data

        break code
      end
    end
  end

  private
  def expired_in_pacific_time?
    pacific_time_zone = 'Pacific Time (US & Canada)'
    expiration = expires_at.in_time_zone(pacific_time_zone)
    Time.use_zone(pacific_time_zone) do
      Time.zone.now >= expiration.midnight + 1.day
    end
  end
end
