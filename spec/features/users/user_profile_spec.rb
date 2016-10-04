require 'rails_helper'

# Feature: User profile
#   As a user
#   I want to interact with my user info
feature 'User profile' do
  context 'user clicks the delete account button' do
    xit 'deletes the account and signs the user out with a flash message' do
      pending 'temporarily disabled until we figure out the MBUN to SSN mapping'
      sign_in_and_2fa_user
      visit profile_path
      click_button t('forms.buttons.delete_account')

      click_button t('forms.buttons.delete_account_confirm')
      expect(page).to have_content t('devise.registrations.destroyed')
      expect(current_path).to eq root_path
      expect(User.count).to eq 0
    end
  end

  describe 'Editing the password' do
    it 'includes the password strength indicator when JS is on', js: true do
      sign_in_and_2fa_user
      click_link 'Edit', href: settings_password_path

      expect(page).to_not have_css('#pw-strength-cntnr.hide')
      expect(page).to have_content '...'

      fill_in 'update_user_password_form_password', with: 'this is a great sentence'
      expect(page).to have_content 'Great'

      find('#pw-toggle-0', visible: false).trigger('click')

      expect(page).to_not have_css('input.password[type="password"]')
      expect(page).to have_css('input.password[type="text"]')

      click_button 'Update'

      expect(current_path).to eq profile_path
    end
  end

  describe 'Regenerating recovery code' do
    it 'displays new code and takes user back to profile page after continuing' do
      user = sign_in_and_2fa_user
      old_code = user.recovery_code

      click_link t('profile.links.regenerate_recovery_code')

      expect(user.reload.recovery_code).to_not eq old_code

      click_button t('forms.buttons.acknowledge_recovery_code')

      expect(current_path).to eq profile_path
    end
  end
end
