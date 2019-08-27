# frozen_string_literal: true

module Admin
  class AccountsController < AdminController
    def show
      @account = current_user
    end

    def edit
      @account = current_user
    end

    def update
      @account = current_user

      if @account.update(account_params)
        bypass_sign_in(@account)

        flash[:success] = t('.success')

        redirect_to edit_admin_account_url, status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@account)

        render 'edit', status: :unprocessable_entity
      end
    end

    private

    def account_params
      params.required(:account).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
  end
end
