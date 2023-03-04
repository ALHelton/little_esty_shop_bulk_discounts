require 'rails_helper'

RSpec.describe 'Bulk Discount Show Page', type: :feature do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    @fifteen = @merchant1.bulk_discounts.create!(percentage_discount: 0.15, quantity_threshold: 15)
    @twenty = @merchant1.bulk_discounts.create!(percentage_discount: 0.20, quantity_threshold: 20)

    visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@fifteen.id}"
  end

  it 'I see the bulk discount`s quantity threshold and percentage discount' do
    expect(page).to have_content("15% Discount")
    expect(page).to have_content("Quantity Threshold: 15")

    expect(page).to_not have_content("20% Discount")
    expect(page).to_not have_content("Quantity Threshold: 30")
  end

  it 'has a link to return to the discount show page' do
    expect(page).to have_link("Back")
    click_link "Back"
    expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/")
  end
end