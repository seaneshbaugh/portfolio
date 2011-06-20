class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	  t.string :name, :salt, :encrypted_password, :cookie_code, :email_address, :first_name, :last_name, :phone_number, :ip_addresses
	  t.integer :privilege_level, :login_count, :post_count
	  t.datetime :last_login
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
