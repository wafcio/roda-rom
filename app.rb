require 'rubygems'
require 'bundler/setup'

require 'roda'
require 'dotenv'
require 'multi_json'
require 'oj'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/slice'
require 'active_support/inflector'

require 'virtus'
require 'rom'
require 'rom-sql'
require 'rom/sql/plugin/pagination'
require_relative 'db/db'
require_relative 'lib/ext_hash'

require_relative 'lib/helpers'
require_relative 'lib/http_basic_authorization'

Dotenv.load

class App < Roda
  include API::Helpers
  include HttpBasicAuthorization

  plugin :heartbeat, path: '/status'
  plugin :multi_route
  plugin :halt
  plugin :hooks
  plugin :all_verbs
  plugin :json
  plugin :json_parser,
    parser: MultiJson.method(:decode),
    error_handler: (lambda do |r|
      r.halt [
        400, { 'Content-Type' => 'application/json' },
        [::MultiJson.encode(code: 400, message: 'Invalid JSON')]
      ]
    end)

  use Rack::Session::Cookie, secret: ENV.fetch('SECRET')
  use Rack::Deflater

  ROM::Error = Class.new(StandardError)

  DB.setup

  before do
    unless request.path == '/'
      require_ssl!
      authorize_api!
    end
  end

  route do |r|
    r.root do
      r.redirect '/status'
    end

    require_relative 'apps/products'

    r.on 'products' do
      r.route 'products'
    end
  end
end
