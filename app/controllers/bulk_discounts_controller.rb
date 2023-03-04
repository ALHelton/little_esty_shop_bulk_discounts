class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new(bulk_discount_params)

    if @bulk_discount.save
      redirect_to "/merchant/#{@merchant.id}/bulk_discounts"
      flash[:success] = "Discount Created Successfully"
    else
      redirect_to "/merchant/#{@merchant.id}/bulk_discounts/new"
      flash[:notice] = "Discount not created: Required information missing"
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
    @discount.update(bulk_discount_params)
    redirect_to "/merchant/#{@merchant.id}/bulk_discounts/#{@discount.id}"
    flash[:success] = "Discount Updated Successfully"
  end

  def destroy
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
    @bulk_discount.destroy
    redirect_to "/merchant/#{@merchant.id}/bulk_discounts"
    flash[:success] = "Discount Deleted Successfully"
  end


  private

  def bulk_discount_params
    params.permit(:percentage_discount, :quantity_threshold, :merchant_id)
  end
end