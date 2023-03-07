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

    describe 'user story 6 and 8' do
      before do
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

        # @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 100, unit_price: 300, status: 0, created_at: "2012-03-29 14:54:09")
        # @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_6.id, quantity: 250, unit_price: 600, status: 0, created_at: "2012-03-29 14:54:09")

        @threeoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.03, quantity_threshold: 10)
        @fiveoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.05, quantity_threshold: 30)
      end
      
      # it '#matched_discounts' do
      #   expect(@ii_1).to eq(nil)
      #   expect(@ii_2).to eq(@threeoff)
      #   expect(@ii_3).to eq(@fiveoff)
      # end

      it '#discounted_items' do
        expect(@invoice_1.discounted_items).to eq([@ii_2, @ii_3])
      end

      it '#discount_total' do
        expect(@invoice_1.discount_total).to eq(454)
      end

      # it 'revenue_total_with_discount' do
      #   expect(@invoice_1.revenue_total_with_discount).to eq(9436)
      # end
    end
  end
end
