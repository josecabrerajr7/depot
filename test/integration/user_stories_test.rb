require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products 

  test "buying a product" do
  	LineItem.delete_all
  	Order.delete_all
  	ruby_book = products(:one)

  	get "/"
  	assert_response :success
  	assert_template "index"
  	
  	xml_http_request :post, '/line_items', product_id: ruby_book.id
  	assert_response :success

  	cart = Cart.find(session[:cart_id])
  	assert_equal 1, cart.line_items.size
  	assert_equal ruby_book, cart.line_items[0].product

  	get "/orders/new"
  	assert_response :success
  	assert_template "new"

  	post_via_redirect "/orders",
  		order: { 
  				 name:      "Dave Thomas",
  				 address:   "965 Vineyard Way, Kingsburg, CA 93631",
  				 email:     "dave@example.org",
  				 pay_type:  "check" 
  				}

  	assert_response :success
  	assert_template "index"
  	cart = Cart.find(session[:cart_id])
  	assert_equal 0, cart.line_items.size

  	orders = Order.all
  	assert_equal 1, orders.size
  	order = orders[0]

  	assert_equal "Dave Thomas",        							             order.name
  	assert_equal "965 Vineyard Way, Kingsburg, CA 93631",     	 order.address
  	assert_equal "dave@example.org",   							             order.email
  	assert_equal "Check",              							             order.pay_type

  	assert_equal 1,  order.line_items.size
  	line_item = order.line_items[0]
  	assert_equal ruby_book, line_item.product

  	mail = ActionMailer::Base.deliveries.last
  	assert_equal ["dave@example.org"], mail.to
  	assert_equal 'Jose Cabrera Jr <rubyonrails85@gmail.com>', mail[:from].value
  	assert_equal "We have received your order, thanks!", mail.subject
  end
end
