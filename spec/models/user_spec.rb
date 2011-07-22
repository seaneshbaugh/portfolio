require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {
      :email_address => "test@test.com",
      :password => "testing123",
      :first_name => "Test",
      :last_name => "User",
      :phone_number => "222-222-2222"
    }
  end

  it "should create a new instance given valid attributes" do
    lambda {
      User.create!(@valid_attributes)
    }.should change(User, :count).by(1)
  end

  context "Validations" do
    [:email_address, :first_name, :last_name, :phone_number, :privilege_level].each do |attr|
      it "must have a #{attr}" do
        user = User.new
        user.should_not be_valid
        user.errors[attr].should include(I18n.t("activerecord.errors.messages.blank"))
      end
    end

    [:cookie_code, :login_count, :post_count].each do |attr|
      it "should create #{attr} before validation" do
        user = User.new
        user.should_not be_valid
        user.errors[attr].should_not include(I18n.t("activerecord.errors.messages.blank"))
      end
    end
  end
end
