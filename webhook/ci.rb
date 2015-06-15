# ci.rb
require 'sinatra'
require 'json'
require 'octokit'

# !!! DO NOT EVER USE HARD-CODED VALUES IN A REAL APP !!!
# Instead, set and test environment variables, like below
ACCESS_TOKEN = ENV['MY_GITHUB_TOKEN']

before do
  @client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
end

post '/payload' do
  @push = JSON.parse(request.body.read)
  
  # @payload = JSON.parse(params[:payload])
  puts @push
  case request.env['HTTP_X_GITHUB_EVENT']
  when "push"
    process_push_data(@push)
  end

  "local CI successful"
end

get '/' do
  "<h1>Hello World!</h1>"
end

def process_push_data(push_data)
  repo = push_data['repository']
  head = push_data['after']
  fullname = repo['full_name']
  sha = head
  puts fullname
  puts sha
  # @client.create_status(fullname, sha, 'pending')

  # for each commit to master do:
  # update repo on device (run the update command)
  # run the ci test
  # if ci test succesful, set status to success, else status to fail
  system("sudo", "bash", "/opt/calmeq-mypi/preinstall/calmeq-init.sh")

  if $?.exitstatus == 0
    puts "no error"
  else
    puts "error running update"
    return [ 500, "error updating local repo" ]
  end

  # ping the QA server
  system( "bash", "/opt/calmeq-mypi/test/pushtest.sh" )

  if $?.exitstatus == 0
    puts "no error on test run"
  else
    puts "error running test"
    return [ 500, "error running test script" ]
  end

  #puts "I got some JSON: #{push.inspect}"

  # update status
  # @client.create_status(fullname, sha, 'success')
  puts "Local CI push processed!"
end
