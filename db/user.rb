class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[github google_oauth2 vkontakte ]
  has_many :questions, foreign_key: 'author_id'
  has_many :answers, foreign_key: 'author_id'
  has_many :rewards, dependent: :nullify
  validates :name, presence: true
  # searchkick

  def self.from_omniauth(auth, emails = [])
    email = (emails.first&.downcase&.strip || auth.info.email&.downcase&.strip).to_s
    if email.blank?
      email = generate_temp_email(auth.uid, auth.provider)
      email_generated = true
    end

    user = User.find_by(email: email)

    if user
      unless user.update(provider: auth.provider, uid: auth.uid)
        Rails.logger.error "Failed to update user: #{user.errors.full_messages.join(', ')}"
      end
    else
      temporary_password = Devise.friendly_token[0, 20]

      user = User.new(
        provider: auth.provider,
        uid: auth.uid,
        email: email,
        name: auth.info.name || auth.info.nickname,
        password: temporary_password
      )

      if email_generated
        user.skip_confirmation_notification!
      else
        user.confirmed_at = Time.now
      end

      unless user.save
        Rails.logger.error "Failed to create user: #{user.errors.full_messages.join(', ')}"
      end
    end

    return user, temporary_password
  end

  def author_of?(resource)
    resource.author_id == id
  end

  private
  def self.generate_temp_email(uid, provider)
    "#{uid}@#{provider}.com"
  end
end
