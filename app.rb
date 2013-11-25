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
  @pulls = github.pull_requests.list(user: 'rails', repo: 'rails', page: params[:page])
  @first_page = URI.parse(@pulls.links.first).query if @pulls.links.first
  @next_page = URI.parse(@pulls.links.next).query if @pulls.links.next
  @prev_page = URI.parse(@pulls.links.prev).query if @pulls.links.prev
  @last_page = URI.parse(@pulls.links.last).query if @pulls.links.last
  slim :pulls
end


