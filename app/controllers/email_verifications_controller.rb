class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create show]

  rate_limit to: 1,
           within: 1.minute,
           only: :create,
           by: -> { params[:email_address].to_s.strip.downcase },
           with: -> {
             redirect_to new_email_verification_path,
                         alert: "Please wait a minute before requesting another verification email."
           }


  def new
  end

  def create
    user = User.find_by(
      email_address: params[:email_address]&.strip&.downcase
    )

    if user && !user.email_verified?
      EmailVerificationMailer
        .with(user: user)
        .verification_email
        .deliver_later
    end

    redirect_to new_session_path,
                notice: "If an unverified account exists for that email address, a new verification email has been sent."
  end

  def show
    user = User.find_by_token_for(
      :email_verification,
      params[:token]
    )

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
