require 'rails_helper'

RSpec.describe 'Bulk Discount Show Page', type: :feature do

  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @fifteen = @merchant1.bulk_discounts.create!(percentage_discount: 0.15, quantity_threshold: 15)
    @twenty = @merchant1.bulk_discounts.create!(percentage_discount: 0.20, quantity_threshold: 20)

    visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@fifteen.id}/edit"
  end

  it 'I see a form to edit the discount, current attributes are prepopulated' do
    expect(page).to have_field("Percentage Discount", with: "0.15")
    expect(page).to have_field("Quantity Threshold", with: "15")
    expect(page).to have_button("Update")

    expect(page).to_not have_field("Percentage Discount", with: "0.25")
    expect(page).to_not have_field("Quantity Threshold", with: "20")
  end

  it 'When I change any/all of the info and click submit, am redirected to discount show page' do
    fill_in("Percentage Discount", with: "0.30")
    fill_in("Quantity Threshold", with: "30")
    click_button("Update")
    expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@fifteen.id}")
  end
end