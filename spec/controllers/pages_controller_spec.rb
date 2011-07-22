require 'spec_helper'

describe PagesController do
  describe "GET index" do
    it "gets the index view" do
      get "index"
      response.status.should be 200
    end

    it "gets the correct index view template" do
      get "index"
      response.should render_template("pages/index")
    end
  end
end