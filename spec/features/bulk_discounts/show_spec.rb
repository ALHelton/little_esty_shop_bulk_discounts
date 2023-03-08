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

  it 'has a link to return to the discount index page' do
    expect(page).to have_link("Back")
    click_link "Back"
    expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/")
  end

  it 'I see a link to edit the bulk discount' do
      expect(page).to have_link("Edit")
  end

  it 'I click edit link and am taken to an edit discount page' do
    click_link("Edit")
    expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@fifteen.id}/edit")
  end

  it 'After submitting edit form, I see that the discount`s attributes have been updated' do
    visit "/merchant/#{@merchant1.id}/bulk_discounts/#{@fifteen.id}/edit"
    fill_in("Percentage Discount", with: "0.40")
    fill_in("Quantity Threshold", with: "50")
    click_button("Update")

    expect(page).to have_content("Discount Updated Successfully")
    expect(page).to have_content("40% Discount")
    expect(page).to have_content("Quantity Threshold: 50")
    expect(page).to_not have_content("15% Discount")
    expect(page).to_not have_content("Quantity Threshold: 15")
  end
end