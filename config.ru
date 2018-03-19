require 'sinatra'
require 'json'
require './test_script'
class App < Sinatra::Base
    set :public_folder, 'static'
    get '/' do
        haml :index
    end
    post '/convert' do
        begin
            payload = params[:code]
            ns = TSNamespace.new(TestExprEnv, TestStatEnv)
            ns.run(payload)
            ns.result
        rescue StandardError => err 
            warn err
            warn $@
            [$!, $@].flatten.join("\n")
        end
    end
end

run App