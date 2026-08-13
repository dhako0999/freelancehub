class AccountsController < ApplicationController
  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(account_params)
      redirect_to account_path,
                  notice: "Your account was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.expect(user: [:email_address])
  end
end
