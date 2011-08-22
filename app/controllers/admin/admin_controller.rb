class Admin::AdminController < ApplicationController
  layout 'admin'

  helper :all

  skip_before_filter :get_current_user

  before_filter :get_current_user, :is_admin?

  before_filter :is_sysop?, :only => :reboot

  def index
    @post = Post.new
  end

  def reboot
    %x[touch "#{File.join(Rails.root, "tmp", "restart.txt")}"]

    flash[:type] = "information"

    flash[:notice] = t "flash.reboot"

    redirect_to admin_root_url and return
  end

  def sql_dump
    database = ActiveRecord::Base.connection

    sql = ""

    database.tables.each do |table|
      #columns = database.columns(table).map(&:name)

      database.select_rows("SELECT * FROM %s" % table).each do |row|
        sql << "INSERT INTO #{table} VALUES(#{row.join(', ')})"
      end

      #sql << "INSERT INTO #{table} (#{columns.join(', ')}) VALUES(go here)"
    end

    flash[:debug] = sql

    redirect_to admin_root_url and return

    #send_file(File.join("private/uploads", @agent_resource.resource_filename))
  end
end
