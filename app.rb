require 'rubygems'
require 'bundler/setup'

require 'roda'
require 'dotenv'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/slice'
require 'active_support/inflector'

# require_relative 'apps/api'

Dotenv.load

class App < Roda
  plugin :heartbeat, path: '/status'

  # enable :sessions, :protection
  # set :session_secret, ENV.fetch('SECRET')

  use Rack::Deflater

  # get '/' do
  #   redirect('/status')
  # end

  route do |r|
  end

  # use API::App
end
