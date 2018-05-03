class Artist < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged
  
  include ReferralCode
  
  scope :active, -> { where(status: "active") }
  
  has_many :medias
  accepts_nested_attributes_for :medias, :allow_destroy => true, :reject_if => :media_reject?
  
  has_many :featureds

  #validates_presence_of :slug, :name, :description
  #validates :slug, uniqueness: true
  
  #before_validation :check_slug
  
  
  # has_attached_file :video_file
  # has_attached_file :audio_file
  #
  has_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  has_attached_file :featured_image
  validates_attachment_content_type :featured_image, :content_type => /\Aimage\/.*\Z/
  
  has_attached_file :facebook_share_image
  validates_attachment_content_type :facebook_share_image, :content_type => /\Aimage\/.*\Z/
  
  validates :website, :format => {:with => URI::regexp(%w(http https)), :message => "needs http://"}, :allow_blank => true
  validates :facebook_url, :format => {:with => URI::regexp(%w(http https)), :message => "needs http://"}, :allow_blank => true
  validates :twitter_url, :format => {:with => URI::regexp(%w(http https)), :message => "needs http://"}, :allow_blank => true
  validates :instagram_url, :format => {:with => URI::regexp(%w(http https)), :message => "needs http://"}, :allow_blank => true
  validates :youtube_url, :format => {:with => URI::regexp(%w(http https)), :message => "needs http://"}, :allow_blank => true
  
  before_save :set_locale
  
  def set_locale #set default locale to en
    unless locale.present?
      self.locale = "en"
    end
  end
  
  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end
  
  def media_reject?(params)
    params[:media_type_id].blank?
  end
  
  def cover_image
    media = self.medias.visible.includes(:media_type).where(:media_type => {:name => "Image"}).order(:order).first
    if media.present?
      return media.media_file
    else
      return nil
    end
  end
  
  def check_slug
    puts "SET SLUG"
    self.slug = self.name.downcase.parameterize
    puts "SLUG: #{self.slug}"
    counter = 0
    loop do
      puts "SLUG LOOP: #{self.slug}"
      if !slug_unique?
        puts "#{counter}"
        counter = counter + 1
        self.slug = "#{self.name.downcase.parameterize}#{counter}"
      else
        break
      end
    end
  end
  
  
  private

  def slug_unique?
    puts "SLUG UNIQUE #{self.slug}"
    scope = Artist.where(slug: self.slug) #check for qr code in current klass
    if self.persisted?
      scope = scope.where('id != ?', self.id) #exclude current record from being checked against itself
    end
    if scope.any?
      puts "NOT UNIQUE"
      return false
    else
      puts "UNIQUE"
      return true
    end
  end
  
  
end
