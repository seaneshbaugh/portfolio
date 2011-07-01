class Admin::AdminController < ApplicationController
	layout 'admin'

	helper :all

	skip_before_filter :maintain_session_and_current_user

	before_filter :maintain_session_and_current_user, :is_admin?

	before_filter :is_sysop?, :only => :reboot

	def index
		#@page_title = "Admin Panel Index"

		#@last_ten_events = LoggerEvent.find(:all, :order => "created_at DESC", :limit => 10)

		#if mobile_browser?
			#render :action => "index_mobile"
		#end
	end

	def reboot
		%x[touch "/home/seaneshb/portfolio/tmp/restart.txt"]

		#LoggerEvent.new(:person => @user, :type => LoggerEvent::EventTypeNotice, :description => "Rails application rebooted.", :visible => true)

		flash[:type] = "information"

		flash[:notice] = "Rebooting Rails. You may need to refresh this page in order to see the changes take effect."

		redirect_to admin_root_url and return
	end

	#private

	#def get_admin_layout
		#if mobile_browser?
			#return "admin_mobile"
		#else
			#return "admin"
		#end
	#end
end
