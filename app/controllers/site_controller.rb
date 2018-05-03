#require 'ahoy'
class SiteController < ApplicationController
  before_filter :set_app
  after_filter :track_action

  def index
  end

  def privacy
  end
  
  def customer_agreement
  end

  def merchant_agreement
  end

  def e_sign_consent
  end

  def commercial_entity_agreement
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end

  private
  def set_app
    if current_admin
      @app = 'admin'
    elsif current_consumer
      @app = 'consumer'
    elsif current_employee
      @app = 'merchant'
    end
  end

  def track_action
    #ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end
end
