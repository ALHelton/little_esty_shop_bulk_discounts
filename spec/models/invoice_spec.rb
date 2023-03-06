require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
    it { should have_many(:bulk_discounts).through(:merchants) }

  end

  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end

    it '#distinct_merchants' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Jewelry')

      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_3 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant_id: @merchant2.id)

      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 4, unit_price: 90, status: 1)
    
      expect(@invoice_1.distinct_merchants).to eq([@merchant1, @merchant2])
    end

    xit '#merchant_rev_with_discount' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Jewelry')
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
      @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
      @item_5 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant_id: @merchant2.id)
      @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant_id: @merchant2.id)
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
      @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)

      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 0, created_at: "2012-03-27 14:54:09")
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 18, unit_price: 100, status: 0, created_at: "2012-03-27 14:54:09")
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 40, unit_price: 200, status: 0, created_at: "2012-03-27 14:54:09")

      @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 100, unit_price: 300, status: 0, created_at: "2012-03-29 14:54:09")
      @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_6.id, quantity: 250, unit_price: 600, status: 0, created_at: "2012-03-29 14:54:09")

      @threeoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.03, quantity_threshold: 10)
      @fiveoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.05, quantity_threshold: 30)
      
      @tenoff = @merchant2.bulk_discounts.create!(percentage_discount: 0.10, quantity_threshold: 100)
      @twentyoff = @merchant2.bulk_discounts.create!(percentage_discount: 0.20, quantity_threshold: 300)

      # expect(@ii_1.discount).to eq(nil)
      expect(@ii_2.discount).to eq(@threeoff)
      expect(@ii_3.discount).to eq(@fiveoff)

      expect(@ii_4.discount).to eq(@tenoff)
      expect(@ii_5.discount).to eq(@tenoff)
    end
  end
end
