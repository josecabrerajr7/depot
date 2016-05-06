class StoreController < ApplicationController
  skip_before_action :authorize
  
  include CurrentCart
  before_action :set_cart
  
  def index
    if params[:set_locale]
      redirect_to store_url(locale: params[:set_locale])
    else
  	   @products = Product.order(:title)
  	   @visits = set_count
    end
  end
  
  private
  def set_count
  	if session[:counter].nil?
  			@visit = 1
  		else
  			@visit = session[:counter] + 1
  	end
  		session[:counter] = @visit
  	end
end
