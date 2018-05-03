class TransactionsController < ApplicationController
  before_filter :authenticate_consumer!
  skip_before_filter :verify_authenticity_token

  def index
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
