class EmailVerificationMailer < ApplicationMailer
    def verification_email
        @user = params[:user]
        @token = @user.generate_token_for(:email_verification)
    
        mail(
          to: @user.email_address,
          subject: "Verify your AI Client Portal email"
        )
    end
end
