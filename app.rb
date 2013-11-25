require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'slim'
require 'github_api'
require 'sinatra/twitter-bootstrap'

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

