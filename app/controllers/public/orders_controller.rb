class Public::OrdersController < ApplicationController

  def new
    @order = Order.new
  end

  def confirm
    @order = Order.new(order_params)
    @cart_items = current_customer.cart_items
    @total_price = 0
    @cart_items.each do |cart_item|
      @total_price += cart_item.subtotal
      #@total_price = cart_item.subtotal + @total_price
    end

    if params[:order][:select_address] == "0"
       @order.postal_code = current_customer.postal_code
       @order.address = current_customer.address
       @order.name = current_customer.last_name + current_customer.first_name
    elsif  params[:order][:select_address] == "1"
            @address = Address.find(params[:order][:address_id])
            @order.postal_code = @address.postal_code
            @order.address = @address.address
            @order.name = @address.name

    elsif params[:order][:select_address] == "2"
          @order.postal_code = params[:order][:postal_code]
          @order.address = params[:order][:address]
          @order.name = params[:order][:name]
    end
  end

  def complete
  end

  def create
    @order = Order.new(order_params)
    @cart_items = current_customer.cart_items
    @total_price = 0
    @cart_items.each do |cart_item|
      #@total_price += cart_item.subtotal
      @total_price = cart_item.subtotal + @total_price
    end
    @order.billing_amount = @order.postage + @total_price.to_i
    if @order.save
      current_customer.cart_items.each do |cart_item|
        @order_detail = OrderDetail.new
        @order_detail.order_id = @order.id
        @order_detail.item_id = cart_item.item_id
        @order_detail.amount = cart_item.amount
        @order_detail.purchase_price = cart_item.item.with_tax_price
        @order_detail.save
      end
      current_customer.cart_items.destroy_all
      redirect_to orders_complete_path
    end
  end

  def index
    @orders = current_customer.orders
    #@order = Order.find(params[:id])
  end

  def show
    @order = Order.find(params[:id])
    @cart_items = current_customer.cart_items
    @total_price = 0
    @cart_items.each do |cart_item|
      #@total_price += cart_item.subtotal
      @total_price = cart_item.subtotal + @total_price
    end


  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :status, :pay_method, :postal_code, :address, :billing_amount, :postage, :name)
  end

  def order_detail_params
    params.require(:order_detail).permit(:order_id, :item_id, :amount, :created_status, :purchase_price)
  end


end