require 'rails_helper'

include SessionTimeoutWarningHelper
include ActionView::Helpers::DateHelper

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in' do
  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign in if not registered' do
    signin('test@example.com', 'Please123!')
    expect(page).to have_content t('devise.failure.not_found_in_database')
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot sign in with wrong email' do
    user = create(:user)
    signin('invalid@email.com', user.password)
    expect(page).to have_content t('devise.failure.not_found_in_database')
  end

  scenario 'user cannot sign in with empty email', js: true do
    signin('', 'foo')

    expect(page).to have_content 'Please fill in this field.'
  end

  scenario 'user cannot sign in with empty password', js: true do
    signin('test@example.com', '')

    expect(page).to have_content 'Please fill in this field.'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with wrong password' do
    user = create(:user)
    signin(user.email, 'invalidpass')
    expect(page).to have_content t('devise.failure.invalid')
  end

  scenario 'user can see and use password visibility toggle', js: true do
    visit new_user_session_path

    find('#pw-toggle-0', visible: false).trigger('click')

    expect(page).to have_css('input.password[type="text"]')
  end

  scenario 'user session expires in amount of time specified by Devise config' do
    sign_in_and_2fa_user

    visit profile_path
    expect(current_path).to eq profile_path

    Timecop.travel(Devise.timeout_in + 1.minute)

    visit profile_path
    expect(current_path).to eq root_path

    Timecop.return
  end

  context 'session approaches timeout', js: true do
    before :each do
      allow(Figaro.env).to receive(:session_check_frequency).and_return(1)
      allow(Figaro.env).to receive(:session_check_delay).and_return(1)
      allow(Figaro.env).to receive(:session_timeout_warning_seconds).
        and_return(Devise.timeout_in)
    end

    scenario 'user sees warning before session times out' do
      sign_in_and_2fa_user
      visit root_path

      expect(page).to have_css('#session-timeout-msg')

      request_headers = page.driver.network_traffic.flat_map(&:headers).uniq

      ajax_headers = { 'name' => 'X-Requested-With', 'value' => 'XMLHttpRequest' }

      expect(request_headers).to include ajax_headers

      find_link(t('forms.buttons.continue_browsing')).trigger('click')

      expect(current_path).to eq profile_path
    end
  end

  context 'signed out' do
    it 'does not display session timeout JS', js: true do
      allow(Rails.application.config).to receive(:session_check_frequency).and_return(1)
      allow(Rails.application.config).to receive(:session_check_delay).and_return(1)
      allow(Rails.application.config).to receive(:session_timeout_warning_seconds).
        and_return(Devise.timeout_in)

      visit root_path
      sleep 2

      expect(page).to_not have_css('#session-timeout-msg')
    end

    it 'does not render session_timeout/warning partial' do
      visit root_path

      expect(page).to_not have_css('#session-timeout-msg', visible: false)
    end
  end

  context 'signing back in after session timeout length' do
    before do
      ActionController::Base.allow_forgery_protection = true
    end

    after do
      ActionController::Base.allow_forgery_protection = false
      Timecop.return
    end

    it 'successfully signs in the user' do
      user = sign_in_and_2fa_user
      click_link(t('links.sign_out'))

      Timecop.travel(Devise.timeout_in + 1.minute)

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button t('links.sign_in')

      expect(page).to_not have_content t('errors.invalid_authenticity_token')
      expect(current_path).to eq user_two_factor_authentication_path
    end
  end

  describe 'session timeout configuration' do
    it 'uses delay and warning settings whose sum is a multiple of 60' do
      expect((start + warning) % 60).to eq 0
    end

    it 'uses frequency and warning settings whose sum is a multiple of 60' do
      expect((frequency + warning) % 60).to eq 0
    end
  end
end
