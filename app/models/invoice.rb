class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :completed]

  
  def distinct_merchants
    merchants.distinct
  end

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  # def discounted_items
  #   invoice_items.joins(:bulk_discounts)
  #   .having('MAX(bulk_discounts.percentage_discount) as discount')
  #   .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
  #   .sum('invoice_items.quantity * invoice_items.unit_price * discount')
  # end

  def discounted_items
    invoice_items.joins(:bulk_discounts)
    .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
    .select('invoice_items.*, MAX(bulk_discounts.percentage_discount) as discount')
    .group(:id)
  end

  def discount_total
    
    discounted_items.sum do |di|
      di.quantity * di.unit_price * di.discount
    end
  end
end
