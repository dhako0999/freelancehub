class RegistrationController < ApplicationController
    allow_unauthenticated_access only: %i[new create]
  
    def new
      @user = User.new
    end
  
    def create
      @user = User.new(registration_params)
  
      if @user.save
        EmailVerificationMailer
          .with(user: @user)
          .verification_email
          .deliver_later
  
        redirect_to new_session_path,
                    notice: "Your account was created. Check your email to verify your account."
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def registration_params
      params.require(:user).permit(
        :email_address,
        :password,
        :password_confirmation
      )
    end
  end
