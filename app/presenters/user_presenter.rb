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
      t('na')
    end
  end

  def email_link
    link_to(tag.i('email', class: 'material-icons'), "mailto:#{@user.email}")
  end

  def last_sign_in_at
    if @user.last_sign_in_at.present?
      @user.last_sign_in_at.strftime(time_format)
    else
      t('na')
    end
  end

  def roles
    @user.roles.pluck(:name).map(&:titleize).join(', ')
  end

  def short_name
    "#{first_name.first.upcase}. #{last_name}"
  end
end
