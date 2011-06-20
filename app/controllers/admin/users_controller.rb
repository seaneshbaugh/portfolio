class Admin::UsersController < Admin::AdminController
	#before_filter :is_admin?, :except => [:edit, :update]

	def index
		@users = User.all
	end

	def show
		@user = User(params[:id])
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])

		unless @user.nil?
			@user.generate_cookie_code

			if @user.save
				#LoggerEvent.new(:person_id => @user.id, :event_type => LoggerEvent::EventTypeObjectCreated, :description => "Created new user #{@person.id} - #{@person.name}.", :visible => true).save

				flash[:type] = "success"

				flash[:notice] = notice_message_created("User " + @user.name)

				redirect_to admin_root_url and return
			else
				flash[:type] = "error"

				flash[:notice] = format_error_messages(@user.errors)

				redirect_to new_admin_user_url and return
			end
		else
			flash[:type] = "error"

			flash[:notice] = error_message_could_not_create("user")

			redirect_to new_admin_person_url and return
		end
	end

	def edit

	end

	def update

	end

	def destroy

	end

	def edit_multiple

	end

	def update_multiple

	end

	def destroy_multiple

	end
end
