
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
   after_action :skip_authorization

   def github
      auth = request.env['omniauth.auth']
      token = auth['credentials']['token']

      emails = GithubApiService.new(token).fetch_user_emails

      @user, temporary_password = User.from_omniauth(auth, emails)

      sign_in_and_redirect @user
   end

   def google_oauth2
      auth = request.env['omniauth.auth']

      @user, temporary_password = User.from_omniauth(auth)
      sign_in_and_redirect @user
   end

   def vkontakte
      auth = request.env['omniauth.auth']

      @user, temporary_password = User.from_omniauth(auth)

      if @user.persisted?
         session[:temporary_password] = temporary_password

         sign_in @user, event: :authentication
         set_flash_message(:notice, :success, kind: 'VKontakte') if is_navigational_format?

         if @user.confirmed?
            redirect_to root_path
         else
            redirect_to edit_user_registration_path, notice: 'Please update and confirm your email and create new password'
         end
      else
         redirect_to new_user_registration_url, alert: "Authentication failed."
      end
   end

end
