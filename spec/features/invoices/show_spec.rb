require 'rails_helper'

RSpec.describe 'invoices show' do
  before :each do

    @merchant1 = Merchant.create!(name: 'Hair Care')
    @merchant2 = Merchant.create!(name: 'Jewelry')

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)
    @item_7 = Item.create!(name: "Scrunchie", description: "This holds up your hair but is bigger", unit_price: 3, merchant_id: @merchant1.id)
    @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)

    @item_5 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant_id: @merchant2.id)
    @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant_id: @merchant2.id)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Kuhn')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-28 14:54:09")

    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
    @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 12, unit_price: 6, status: 1)
    @ii_12 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 8, unit_price: 90, status: 1)

    @ii_13 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 4, unit_price: 360, status: 1)
    @ii_14 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_6.id, quantity: 7, unit_price: 20, status: 1)

    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_3.id, quantity: 3, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_2.id)

    @threeoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.03, quantity_threshold: 5)
    @fiveoff = @merchant1.bulk_discounts.create!(percentage_discount: 0.05, quantity_threshold: 8)
    
    @tenoff = @merchant2.bulk_discounts.create!(percentage_discount: 0.10, quantity_threshold: 10)
    @twentyoff = @merchant2.bulk_discounts.create!(percentage_discount: 0.20, quantity_threshold: 20)
  end

  it "shows the invoice information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@invoice_1.id)
    expect(page).to have_content(@invoice_1.status)
    expect(page).to have_content(@invoice_1.created_at.strftime("%A, %B %-d, %Y"))
  end

  it "shows the customer information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@customer_1.first_name)
    expect(page).to have_content(@customer_1.last_name)
    expect(page).to_not have_content(@customer_2.last_name)
  end

  it "shows the item information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_1.unit_price)
    expect(page).to_not have_content(@ii_4.unit_price)

  end

  it "shows the total revenue for this invoice" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@invoice_1.total_revenue)
  end

  it "shows a select field to update the invoice status" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    within("#the-status-#{@ii_1.id}") do
      page.select("cancelled")
      click_button "Update Invoice"

      expect(page).to have_content("cancelled")
     end

     within("#current-invoice-status") do
       expect(page).to_not have_content("in progress")
     end
  end

  it 'I see the total revenue for my merchant from this invoice (not including discounts)' do
    visit merchant_invoice_path(@merchant1, @invoice_1)
      within "#revenue_totals" do
        expect(page).to have_content("Hair Care revenue subtotal: $8.82")
        expect(page).to_not have_content("Jewelry revenue subtotal: $15.80")
      end
    end

  it 'I see the total discounted revenue for my merchant from this invoice incl bulk discounts' do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    within "#revenue_totals" do
      expect(page).to have_content("Hair Care total revenue after discount: $8.38")
      expect(page).to_not have_content("Jewelry total revenue after discount: $14.22")
    end
  end

  it 'Next to each invoice item I see a link to the show page for the bulk discount that was applied' do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    within "#the-status-#{@ii_1.id}" do
      expect(page).to have_link("5% Discount")
    end

    within "#the-status-#{@ii_11.id}" do
      expect(page).to have_link("5% Discount")
    end

    within "#the-status-#{@ii_12.id}" do
      expect(page).to have_link("5% Discount")
    end
  end

  it  'when I click the discount link, it takes me to the discount show page' do
    @merchant = Merchant.create!(name: 'Kitchen')
    @it1 = Item.create!(name: "knife", description: "its a knife", unit_price: 10, merchant_id: @merchant.id, status: 1)
    @it2 = Item.create!(name: "spoon", description: "its a spoon", unit_price: 20, merchant_id: @merchant.id, status: 1)
    @it3 = Item.create!(name: "fork", description: "its a fork", unit_price: 30, merchant_id: @merchant.id, status: 1)
    @customer = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @invoice = Invoice.create!(customer_id: @customer.id, status: 2, created_at: "2012-03-27 14:54:09")

    @ii1 = InvoiceItem.create!(invoice_id: @invoice.id, item_id: @it1.id, quantity: 5, unit_price: 10, status: 2)
    @ii2 = InvoiceItem.create!(invoice_id: @invoice.id, item_id: @it2.id, quantity: 1, unit_price: 10, status: 2)
    @ii3 = InvoiceItem.create!(invoice_id: @invoice.id, item_id: @it3.id, quantity: 3, unit_price: 10, status: 2)

    @five = @merchant.bulk_discounts.create!(percentage_discount: 0.05, quantity_threshold: 5)
    @three = @merchant.bulk_discounts.create!(percentage_discount: 0.03, quantity_threshold: 3)
    
    visit merchant_invoice_path(@merchant, @invoice)
    within "#the-status-#{@ii3.id}" do
      click_link("3% Discount")
      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@three.id}")
    end

    visit merchant_invoice_path(@merchant, @invoice)
    within "#the-status-#{@ii1.id}" do
      click_link("5% Discount")
      expect(current_path).to eq("/merchant/#{@merchant.id}/bulk_discounts/#{@five.id}")
    end

    visit merchant_invoice_path(@merchant, @invoice)
    within "#the-status-#{@ii2.id}" do
      expect(page).to have_content("N/A")
    end
  end
end
