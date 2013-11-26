require File.expand_path '../spec_helper.rb', __FILE__

describe "Github Stats Application" do

  it "should allow accessing the index page" do
    get '/'
    last_response.should be_ok
  end

  it "should render commits activity" do
    get '/commit_activity'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render pulls" do
    get '/pulls'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render reviews" do
    get '/reviews'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render issues" do
    get '/issues'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render comments" do
    get '/comments'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render commits" do
    get '/commits'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render active_users" do
    get '/active_users'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

  it "should render last_day_active_users" do
    get '/last_day_active_users'
    last_response.should be_ok
    last_response.body.should_not be_empty
  end

end