require "sinatra/base"
require './lib/space'
require './lib/user'
require './lib/booking'
require './database_connection_setup'
require 'sinatra/flash'

class MakersBnB < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  get "/test" do
    "Testing infrastructure: self.code"
  end

  get "/" do
    erb :index
  end

  post "/users" do
    user = User.create(
      name: params['name'],
      username: params['username'],
      email: params['email'],
      password: params['password']
      )
    session[:user_id] = user.id
    redirect :spaces
  end

  post "/sessions" do
    user = User.authenticate(email: params[:log_email], password: params[:log_password])
    if user
      session[:user_id] = user.id
      redirect :spaces
    else
      flash[:notice] = 'Please check your email or password.'
      redirect '/'
    end
  end

  post '/sessions/destroy' do
    session.clear
    redirect '/'
  end

  get "/spaces" do
    @user = User.find(id: session[:user_id])
    @spaces = Space.all
    erb :'spaces/spaces'
  end

  get "/spaces/new" do
    erb :'spaces/new'
  end

  post "/spaces" do
    @date_from = Date.parse(params[:date_from]).strftime('%Y-%m-%d')
    @date_to = Date.parse(params[:date_to]).strftime('%Y-%m-%d')
    Space.create(
      name: params[:name],
      description: params[:description],
      price: params[:price],
      date_from: @date_from,
      date_to: @date_to,
      user_id: session[:user_id]
      )
    redirect :spaces
  end

  get "/spaces/calendar" do
    @space_id = session[:space_id]
    erb :"spaces/calendar"
  end

  post "/calendar" do
    session[:space_id] = params[:space_id]
    session[:user_id]
    @date_start = Date.parse(params[:trip_start]).strftime('%Y-%m-%d')
    @date_end = Date.parse(params[:trip_end]).strftime('%Y-%m-%d')
    Booking.create(
      start_date: @date_start,
      end_date: @date_end,
      space_id: session[:space_id],
      user_id: session[:user_id]
      )
    erb :'spaces/confirmation'
  end

  run! if app_file == $0
end
