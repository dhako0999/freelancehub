class EmailVerificationsController < ApplicationController
    allow_unauthenticated_access only: :show
  
    def show
      user = User.find_by_token_for(:email_verification, params[:token])
  
      if user
        user.update!(email_verified_at: Time.current)
  
        redirect_to new_session_path,
                    notice: "Your email address has been verified. You can now sign in."
      else
        redirect_to new_session_path,
                    alert: "That verification link is invalid or has expired."
      end
    end
  end
