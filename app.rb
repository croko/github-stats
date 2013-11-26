require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'github_api'

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

get "/" do
  haml :index
end

get "/commit_activity" do
  @commits = github.repos.stats.commit_activity

  @data = []
  @commits.each do |commit|
    @data << {date: Time.at(commit.week).utc, commits: commit.total}
  end

  @data = @data.to_json

  haml :commit_activity

end

get '/pulls' do
  @pulls = github.pull_requests.list(page: params[:page])
  @first_page = URI.parse(@pulls.links.first).query if @pulls.links.first
  @next_page = URI.parse(@pulls.links.next).query if @pulls.links.next
  @prev_page = URI.parse(@pulls.links.prev).query if @pulls.links.prev
  @last_page = URI.parse(@pulls.links.last).query if @pulls.links.last
  haml :pulls
end

get '/reviews' do
  @comments = github.pull_requests.comments.list(page: params[:page])

  @first_page = URI.parse(@comments.links.first).query if @comments.links.first
  @next_page = URI.parse(@comments.links.next).query if @comments.links.next
  @prev_page = URI.parse(@comments.links.prev).query if @comments.links.prev
  @last_page = URI.parse(@comments.links.last).query if @comments.links.last
  haml :reviews
end

get '/issues' do
  @issues = github.activity.events.issue(page: params[:page])
  @first_page = URI.parse(@issues.links.first).query if @issues.links.first
  @next_page = URI.parse(@issues.links.next).query if @issues.links.next
  @prev_page = URI.parse(@issues.links.prev).query if @issues.links.prev
  @last_page = URI.parse(@issues.links.last).query if @issues.links.last

  haml :issues
end

get '/comments' do
  @comments = github.issues.comments.list(page: params[:page])

  @first_page = URI.parse(@comments.links.first).query if @comments.links.first
  @next_page = URI.parse(@comments.links.next).query if @comments.links.next
  @prev_page = URI.parse(@comments.links.prev).query if @comments.links.prev
  @last_page = URI.parse(@comments.links.last).query if @comments.links.last

  haml :comments
end

get '/commits' do
  #was chosen small repo to avoid exceeding the rate limit
  @commits = github.repos.commits.list(user: 'ryanb', repo: 'letter_opener', auto_pagination: true)
  haml :commits
end

get '/active_users' do
  @commits = github.repos.commits.list(since: Time.now.localtime - 1.hour)
  @commiters = []
  @commiters_all = []

  @commits.to_a.each do |c|
    @commiters_all << {'author' => c.commit.author.name}
  end

  @commiters_all.uniq.each do |c|
    @commiters << {'author' => c['author'], 'commits' => @commiters_all.count(c)}
  end
  @commiters = @commiters.sort_by { |d| d['commits'] }.reverse
  haml :active_users
end

get '/last_day_active_users' do
  @commits = github.repos.commits.list(since: Date.today.beginning_of_day)
  @commiters = []
  @commiters_all = []

  @commits.to_a.each do |c|
    @commiters_all << {'author' => c.commit.author.name}
  end

  @commiters_all.uniq.each do |c|
    @commiters << {'author' => c['author'], 'commits' => @commiters_all.count(c)}
  end
  @commiters = @commiters.sort_by { |d| d['commits'] }.reverse
  haml :last_day_active_users
end

