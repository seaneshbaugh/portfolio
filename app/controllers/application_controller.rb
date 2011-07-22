require 'possessive'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_current_user

=begin
  before_filter :maintain_session_and_current_user

  def maintain_session_and_current_user
    if session[:id]
      if @application_session = Session.find_by_id(session[:id])
        @application_session.update_attributes(:ip_address => request.remote_addr, :path => request.path_info)

        @current_user = @application_session.user
      else
        session[:id] = nil

        redirect_to root_url and return
      end
    else
      unless cookies[:remember_me_id].nil?
        @current_user = User.find_by_id(cookies[:remember_me_id])

        unless @current_user.nil?
          if cookies.permanent[:remember_me_code] == Digest::SHA256.hexdigest(@current_user.cookie_code)
            @session = @current_user.sessions.create

            session[:id] = @session.id

            if @application_session = Session.find_by_id(session[:id])
              @application_session.update_attributes(:ip_address => request.remote_addr, :path => request.path_info)

              @current_user = @application_session.user

              @current_user.last_login = Time.now

              @current_user.save
            else
              session[:id] = @current_user = nil

              cookies.delete :remember_me_id

              cookies.delete :remember_me_code

              redirect_to root_url and return
            end
          else
            cookies.delete :remember_me_id

            cookies.delete :remember_me_code
          end
        else
          cookies.delete :remember_me_id

          cookies.delete :remember_me_code
        end
      end
    end
  end
=end

  def ensure_login
    if @current_user.nil?
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.must_be_logged_in"

      redirect_to root_url and return
    end
  end

  def ensure_logout
    unless @current_user.nil?
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.already_logged_in"

      redirect_to root_url and return
    end
  end

  def is_moderator?
    if @current_user.nil?
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.must_be_logged_in"

      redirect_to root_url and return
    end

    if @current_user.privilege_level < User::PrivilegeLevelModerator
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.not_authorized"

      redirect_to :back and return
    end
  end

  def is_admin?
    if @current_user.nil?
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.must_be_logged_in"

      redirect_to root_url and return
    end

    if @current_user.privilege_level < User::PrivilegeLevelAdmin
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.not_authorized"

      redirect_to :back and return
    end
  end

  def is_sysop?
    if @current_user.nil?
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.must_be_logged_in"

      redirect_to root_url and return
    end

    if @current_user.privilege_level < User::PrivilegeLevelSysOp
      flash[:type] = "attention"

      flash[:notice] = t "flash.access.not_authorized"

      redirect_to :back and return
    end
  end

  def validation_errors_for(object)
    "<ul>" + object.errors.map {|attribute, message| "<li>#{t("flash.error") + object.class.human_attribute_name("#{attribute.to_s}")} #{message}.</li>"}.to_s + "</ul>"
  end

  private

  def get_current_user
    @current_user ||= User.find_by_remember_me_token(cookies[:remember_me_token]) if cookies[:remember_me_token]
  end
end
