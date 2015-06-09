# ci.rb
require 'sinatra'
require 'json'

post '/payload' do
  push = JSON.parse(request.body.read)
 
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

  # puts "I got some JSON: #{push.inspect}"
  "local CI successful"
end

get '/' do
  "<h1>Hello World!</h1>"
end
