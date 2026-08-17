class AccountsController < ApplicationController
  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    old_email = @user.email_address
  
    if @user.update(account_params)
      if @user.email_address != old_email
        @user.update!(email_verified_at: nil)
  
        EmailVerificationMailer
          .with(user: @user)
          .verification_email
          .deliver_later
  
        terminate_session
  
        redirect_to new_session_path,
                    notice: "Your email address was updated. Check your new email to verify it before signing in."
      else
        redirect_to account_path,
                    notice: "Your account was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.expect(user: [:email_address])
  end
end
