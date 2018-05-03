class MerchantController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :set_app

  private
  def set_app
    @app = 'merchant'
    if current_employee
      @merchant = current_employee.merchant
    end
  end

end
