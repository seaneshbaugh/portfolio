# frozen_string_literal: true

class UserPresenter < BasePresenter
  def initialize(user, template)
    super

    @user = user
  end

  def current_sign_in_at
    if @user.current_sign_in_at.present?
      @user.current_sign_in_at.strftime(time_format)
    else
      'N/A'
    end
  end

  def email_link
    link_to '<span class="glyphicon glyphicon-envelope">'.html_safe, "mailto:#{@user.email}", rel: 'tooltip', title: 'Send Email'
  end

  def last_sign_in_at
    if @user.last_sign_in_at.present?
      @user.last_sign_in_at.strftime(time_format)
    else
      'N/A'
    end
  end

  def roles
    @user.roles.pluck(:name).map { |role| role.titleize }.join(', ')
  end

  def short_name
    "#{first_name.first.upcase}. #{last_name}"
  end
end
