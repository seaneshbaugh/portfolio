require 'spec_helper'

describe Post do
  it "should save when associated with a valid user" do
    lambda {
      p = Post.create({ :title => "test", :slug => "test", :user_id => 1, :status => 1, :private => true })
      p.user.should_not be(nil)
      p.user.valid?.should be(true)
      p.valid?.should be(true)
    }
  end

  it "should not save when not associated with a valid user" do
    lambda {
      p = Post.create({ :title => "test", :slug => "test", :user_id => 9000, :status => 1, :private => true })
      p.user.should be(nil)
      p.user.valid?.should be(false)
      p.valid?.should be(false)
    }
  end
end
