class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  validates :percentage_discount, :quantity_threshold, presence: :true
  validates :percentage_discount, numericality: { only_float: true, greater_than: 0, less_than: 1.01 }
  validates :quantity_threshold, numericality: { only_integer: true, greater_than: 0, less_than: 100001 }
end