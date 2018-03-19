require 'sinatra'

class App < Sinatra::Base
    get '/' do
        "Hello"
    end
end

run App