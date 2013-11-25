require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'slim'
require 'github_api'
require 'v8'

set :slim, pretty: true

db = URI.parse('postgres://gennady@localhost/github')

ActiveRecord::Base.establish_connection(
    :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
)

github = Github.new do |config|
  config.repo = 'rails'
  config.user = 'rails'
end

get '/application.js' do
  coffee :script
end

get "/" do
  slim :index
end

get "/commit_activity" do
  @commits = github.repos.stats.commit_activity
  slim :commit_activity
end

get '/pulls' do
  @pulls = github.pull_requests.list(page: params[:page])
  @first_page = URI.parse(@pulls.links.first).query if @pulls.links.first
  @next_page = URI.parse(@pulls.links.next).query if @pulls.links.next
  @prev_page = URI.parse(@pulls.links.prev).query if @pulls.links.prev
  @last_page = URI.parse(@pulls.links.last).query if @pulls.links.last
  slim :pulls
end

get '/reviews' do
  @comments = github.pull_requests.comments.list(page: params[:page])

  @first_page = URI.parse(@comments.links.first).query if @comments.links.first
  @next_page = URI.parse(@comments.links.next).query if @comments.links.next
  @prev_page = URI.parse(@comments.links.prev).query if @comments.links.prev
  @last_page = URI.parse(@comments.links.last).query if @comments.links.last
  slim :reviews
end

get '/issues' do
  @issues = github.activity.events.issue(page: params[:page])
  @first_page = URI.parse(@issues.links.first).query if @issues.links.first
  @next_page = URI.parse(@issues.links.next).query if @issues.links.next
  @prev_page = URI.parse(@issues.links.prev).query if @issues.links.prev
  @last_page = URI.parse(@issues.links.last).query if @issues.links.last

  slim :issues
end

get '/comments' do
  @comments = github.issues.comments.list(page: params[:page])

  @first_page = URI.parse(@comments.links.first).query if @comments.links.first
  @next_page = URI.parse(@comments.links.next).query if @comments.links.next
  @prev_page = URI.parse(@comments.links.prev).query if @comments.links.prev
  @last_page = URI.parse(@comments.links.last).query if @comments.links.last

  slim :comments
end


