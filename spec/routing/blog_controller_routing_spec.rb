require "spec_helper"

describe BlogController do

  describe "index" do
  	# subject { controller }
  	
    it "should route to /blog/index { :format => 'html' } through GET" do
        { :get => '/' }.should route_to(:controller => 'blog', :action => 'index')   
    end
  end
  
end