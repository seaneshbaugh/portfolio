require 'messages'

class ApplicationController < ActionController::Base
	include Messages

	protect_from_forgery

	before_filter :maintain_session_and_current_user

	def maintain_session_and_current_user
		if session[:id]
			if @application_session = Session.find(session[:id])
				@application_session.update_attributes(:ip_address => request.remote_addr, :path => request.path_info)

				@current_user = @application_session.user
			else
				session[:id] = nil

				redirect_to root_url and return
			end
		else
			unless cookies[:remember_me_id].nil?
				@current_user = User.find(cookies[:remember_me_id])

				unless @current_user.nil?
					if cookies[:remember_me_code] == Digest::SHA256.hexdigest(@current_user.cookie_code)
						@session = @current_user.sessions.create

						#LoggerEvent.new(:person => @session.person, :event_type => LoggerEvent::EventTypeLogin, :description => "#{@session.person.name} has logged in from #{request.remote_ip}.", :visible => true).save

						session[:id] = @session.id

						if @application_session = Session.find(session[:id])
							@application_session.update_attributes(:ip_address => request.remote_addr, :path => request.path_info)

							@current_user = @application_session.person

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

	def ensure_login
		if @current_user.nil?
			flash[:type] = "attention"

			flash[:notice] = "You must be logged in to view this page."

			redirect_to root_url and return
		end
	end

	def ensure_logout
		unless @current_user.nil?
			flash[:type] = "attention"

			flash[:notice] = "You are already logged in."

			redirect_to root_url and return
		end
	end

	def is_moderator?
		if @current_user.nil?
			flash[:type] = "attention"

			flash[:notice] = "You must be logged in to view this page."

			redirect_to root_url and return
		end

		unless @current_user.is_moderator?
			flash[:type] = "attention"

			flash[:notice] = "You are not authorized to view this page."

			redirect_to :back and return
		end
	end

	def is_admin?
		if @current_user.nil?
			flash[:type] = "attention"

			flash[:notice] = "You must be logged in to view this page."

			redirect_to root_url and return
		end

		unless @current_user.is_admin?
			flash[:type] = "attention"

			flash[:notice] = "You are not authorized to view this page."

			redirect_to :back and return
		end
	end

	def is_sysop?
		if @current_user.nil?
			flash[:type] = "attention"

			flash[:notice] = "You must be logged in to view this page."

			redirect_to root_url and return
		end

		if @current_user.is_sysop?
			flash[:type] = "attention"

			flash[:notice] = "You are not authorized to view this page."

			redirect_to :back and return
		end
	end
end
