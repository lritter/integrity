require "init"
require 'integrity/auth_middleware'
require 'integrity/simple_user'

use UserAuthentication, 
  :find_user_by => lambda { |username, env| Integrity::SimpleUser.first(:username => username) },
  :authenticate_with =>  lambda { |user, auth_request| user.authenticate(auth_request.credentials.last) },
  :pass => Integrity.config.github ? %r{^POST /github/#{Integrity.config.github_token}$} : []

run Integrity.app
