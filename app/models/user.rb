class User < ActiveRecord::Base
  include NonNullUuid

  after_validation :set_default_role, if: :new_record?

  devise :confirmable, :database_authenticatable, :recoverable, :registerable,
         :timeoutable, :trackable, :two_factor_authenticatable, :omniauthable,
         :zxcvbnable,
         omniauth_providers: [:saml]

  enum role: { user: 0, tech: 1, admin: 2 }

  has_one_time_password

  has_many :authorizations, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :events, dependent: :destroy

  attr_accessor :asserted_attributes

  def set_default_role
    self.role ||= :user
  end

  def need_two_factor_authentication?(_request)
    two_factor_enabled?
  end

  def two_factor_enabled?
    phone.present?
  end

  def send_two_factor_authentication_code(_code)
    # The two_factor_authentication gem assumes that if a user needs to receive
    # a code, the code should be automatically sent right after Warden signs
    # the user in by calling this method. However, we don't want a code to be
    # automatically sent until the user has reached the TwoFactorAuthenticationController,
    # where we prompt them to select how they would like to receive the OTP code.
    # Sending an OTP code is not a User responsibility. It belongs either in the
    # controller, or in a dedicated class that the controller sends messages to.
    # Based on the delivery method chosen by the user, the controller calls the
    # appropriate background job to send the code, such as SmsSenderOtpJob.
    #
    # Hence, we define this method as a no-op method, meaning it doesn't do anything.
    # See https://github.com/18F/identity-idp/pull/452 for more details.
  end

  def confirmation_period_expired?
    confirmation_sent_at && confirmation_sent_at.utc <= self.class.confirm_within.ago
  end

  def send_reset_confirmation
    update(reset_requested_at: Time.current, confirmed_at: nil)
    send_confirmation_instructions
  end

  def first_identity
    active_identities[0]
  end

  def last_identity
    active_identities[-1] || NullIdentity.new
  end

  def active_identities
    identities.where(
      'session_uuid IS NOT ?',
      nil
    ).order(
      last_authenticated_at: :asc
    ) || []
  end

  def multiple_identities?
    active_identities.size > 1
  end

  def active_profile
    profiles.find(&:active?)
  end

  # To send emails asynchronously via ActiveJob.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def decorate
    UserDecorator.new(self)
  end

  private

  # used by zxcvbn
  def weak_words
    [APP_NAME]
  end

  # method required by zxcvbn
  def password_required?
    confirmable = confirmed? || confirmation_token.present?
    password.present? && confirmable
  end
end
