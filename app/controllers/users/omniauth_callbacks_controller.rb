class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env['omniauth.auth']
    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      # If no identity was found, create a brand new one here
      @identity = Identity.create_with_omniauth(auth)
    end
    # binding.pry
    if signed_in?
      if @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        redirect_to root_url, notice: "Already linked that account!"
      else
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        redirect_to root_url, notice: "Successfully linked that account!"
      end
    else
      if @identity.user.present?
        # The identity we found had a user associated with it so let's
        # just log them in here
        self.current_user = @identity.user
        redirect_to root_url, notice: "Signed in!"
      else
        user = User.from_omniauth(auth)
        if user.persisted?
         @identity.user_id = user.id
         @identity.save
         sign_in_and_redirect user, :event => :authentication #this will throw if @user is not activated
         set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
       else
         session["devise.facebook_data"] = request.env["omniauth.auth"]
         redirect_to new_user_registration_url
       end
      end
    end
  end
end
