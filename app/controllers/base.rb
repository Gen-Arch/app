require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'rack/contrib'

class Base < Sinatra::Base
  configure do
    use Rack::PostBodyContentTypeParser
    set :server, :puma
    set :root, File.expand_path('../../', __dir__)
    set :public_folder, File.join(root, 'app', 'dist')
    set :views, File.join(root, 'app', 'dist')
    enable :logging
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader

    #cros対応
    register Sinatra::CrossOrigin
    enable :cross_origin
    set :allow_origin, :any
    set :allow_methods, [:get, :post, :options]
    set :allow_credentials, true
    set :max_age, "1728000"
    set :expose_headers, ['Content-Type']
  end

  before do
    cross_origin if development?
    request.script_name = ENV['RELATIVE_URL_ROOT'] || '/'
  end

  helpers do
    def protected!
      unless request.request_method  == 'OPTIONS' || authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def  authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      username = ENV['BASIC_AUTH_USERNAME']
      password = ENV['BASIC_AUTH_PASSWORD']
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
    end
  end

  if development?
    options '*' do
      response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
      response.headers["Access-Control-Allow-Origin"] = "*"
      status 200
    end
  end
end
