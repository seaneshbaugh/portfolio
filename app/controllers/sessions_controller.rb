require 'digest/sha2'

class SessionsController < ApplicationController
	before_filter :ensure_login, :only => :destroy
	before_filter :ensure_logout, :only => [:new, :create, :recovery]

	def new
		@session = Session.new
	end

	def create
		@session = Session.new(params[:session])

		unless @session.nil?
			if @session.save
				session[:id] = @session.id

				user = @session.user

				user.update_ip_log(request.remote_ip)

				if params[:remember_me] == "1"
					if user.cookie_code.blank? or params[:limit_session] == "1"
						user.generate_cookie_code
					end

					#cookies[:remember_me_id] = { :value => user.id.to_s, :expires => 365.days.from_now }

					#cookies[:remember_me_code] = { :value => Digest::SHA256.hexdigest(user.cookie_code), :expires => 365.days.from_now }

					cookies.permanent[:remember_me_id] =  user.id.to_s

					cookies.permanent[:remember_me_code] = Digest::SHA256.hexdigest(user.cookie_code)
				end

				user.last_login = Time.now

				if user.login_count.nil?
					user.login_count = 0
				end

				user.login_count.to_i += 1

				user.save

				flash[:type] = "success"

				flash[:notice] = t "flash.session.success.login", :user_name => user.name

				redirect_to root_url and return
			else
				flash[:type] = "error"

				flash[:notice] = t "flash.session.error.login"

				render :action => "new" and return
			end
		else
			flash[:type] = "error"

			flash[:notice] = t "flash.session.error.could_not_create"

			redirect_to new_session_url and return
		end
	end

	def destroy
		Session.destroy(@application_session)

		session[:id] = @current_user = nil

		unless cookies[:remember_me_id].nil?
			cookies.delete :remember_me_id
		end

		unless cookies[:remember_me_code].nil?
			cookies.delete :remember_me_code
		end

		flash[:type] = "information"

		flash[:notice] = t "flash.session.success.logout"

		redirect_to root_url and return
	end

	def recovery
		begin
			key = Crypto.decrypt(params[:id]).split(/:/)

			@session = User.find(key[0], :conditions => {:salt => key[1]}).sessions.create

			session[:id] = @session.id

			flash[:type] = "attention"

			flash[:notice] = t "flash.sessions.success.change_password"

			redirect_to root_url and return
		rescue ActiveRecord::RecordNotFound
			flash[:type] = "error"

			flash[:notice] = t "flash.sessions.error.recovery_link"

			redirect_to new_session_url and return
		end
	end
end
