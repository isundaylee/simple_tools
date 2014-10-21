require 'sinatra'
require 'securerandom'
require 'fileutils'

set :bind, '0.0.0.0'
set :port, 10037

LOCKS_DIR = '/tmp/simple_lock'

def lock_file(name)
  FileUtils.mkdir_p(LOCKS_DIR)
  File.join(LOCKS_DIR, name)
end

get '/lock/:name'  do
  name = params[:name]
  name.strip! unless name.nil?

  return '0' if (name.nil? || name.empty?)

  file = lock_file(name)

  return '0' if File.exists?(file)

  File.write(file, SecureRandom.hex)
  return '1'
end

get '/unlock/:name/:code' do
  name = params[:name].strip
  code = params[:code].strip
  file = lock_file(name)

  return '0' unless File.exists?(file)
  return '0' unless File.read(file).strip == code

  FileUtils.rm(file)
  return '1'
end
