class Admin::UsersController < Admin::AdminController
	def index
		@users = User.all

		if params[:survey] == "1"
			render :action => "survey"
		end
	end

	def show
		@user = User.find_by_id(params[:id])

		if @user.nil?
			flash[:type] = "error"

			flash[:notice] = t "flash.user.error.could_not_find"

			redirect_to admin_users_url and return
		end
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])

		unless @user.nil?
			if @user.privilege_level > @current_user.privilege_level
				flash[:type] = "attention"

				flash[:notice] = t "flash.user.error.privilege_level_create"

				render :action => :new and return
			end

			@user.generate_cookie_code

			if @user.save
				flash[:type] = "success"

				flash[:notice] = t "flash.user.success.created", :user_name => @user.name

				redirect_to admin_users_url and return
			else
				flash[:type] = "error"

				flash[:notice] = validation_errors_for(@user)

				render :action => :new and return
			end
		else
			flash[:type] = "error"

			flash[:notice] = t "flash.user.error.could_not_create"

			redirect_to new_admin_user_url and return
		end
	end

	def edit
		@user = User.find_by_id(params[:id])

		if @user.nil?
			flash[:type] = "error"

			flash[:notice] = t "flash.user.error.could_not_find"

			redirect_to admin_users_url and return
		end

		if @user.privilege_level >= @current_user.privilege_level
			flash[:type] = "attention"

			flash[:notice] = t "flash.user.error.privilege_level_edit"

			redirect_to :back and return
		end
	end

	def update
		@user = User.find_by_id(params[:id])

		unless @user.nil?
			if  @user.privilege_level >= @current_user.privilege_level
				flash[:type] = "attention"

				flash[:notice] = t "flash.user.error.privilege_level_edit"

				redirect_to :back and return
			end

			if params[:user].privilege_level > @current_user.privilege_level
				flash[:type] = "attention"

				flash[:notice] = t "flash.user.error.privilege_level_update"

				render :action => :edit and return
			end

			if @user.update_attributes(params[:person])
				flash[:type] = "success"

				flash[:notice] = t "flash.user.success.updated", :user_name => @user.name.possessive

				redirect_to admin_user_url(@user) and return
			else
				flash[:type] = "error"

				flash[:notice] = validation_errors_for(@user)

				render :action => :edit and return
			end
		else
			flash[:type] = "error"

			flash[:notice] = t "flash.user.error.could_not_find"

			redirect_to admin_users_url and return
		end
	end

	def destroy
		@user = User.find_by_id(params[:id])

		unless @user.nil?
			if @user == @current_user
				User.destroy(@user)

				session[:id] = @current_user = nil

				flash[:type] = "success"

				flash[:notice] = t "flash.user.success.destroyed", :user_name => "Your"

				redirect_to root_url and return
			else
				if @user.privilege_level < @current_user.privilege_level
					User.destroy(@user)

					flash[:type] = "success"

					flash[:notice] = t "flash.user.success.destroyed", :user_name => @user.name.possessive

					redirect_to admin_users_url and return
				else
					flash[:type] = "error"

					flash[:notice] = t "flash.user.error.privilege_level_destroy"

					redirect_to admin_users_url and return
				end
			end
		else
			flash[:type] = "error"

			flash[:notice] = t "flash.user.error.could_not_find"

			redirect_to admin_users_url and return
		end
	end

	def edit_multiple

	end

	def update_multiple

	end

	def destroy_multiple

	end
end
