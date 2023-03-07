require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many(:items).through(:merchant) }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:invoices).through(:invoice_items) }

  end

  describe 'validations' do
    it { should validate_presence_of :percentage_discount }
    it { should validate_presence_of :quantity_threshold }
    it { should validate_numericality_of :percentage_discount }
    it { should validate_numericality_of :quantity_threshold }
  end

  describe 'instance methods' do
    before do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @fiveoff = @m1.bulk_discounts.create!(percentage_discount: 0.05, quantity_threshold: 5)
    end

    it 'formatted_percentage' do
      expect(@fiveoff.formatted_percentage).to eq('5%')
    end
  end
end