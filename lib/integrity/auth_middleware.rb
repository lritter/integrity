
class UserAuthentication
  attr_accessor :auth_request
  attr_accessor :app
  attr_accessor :find_user_by
  attr_accessor :authenticate_with
  attr_accessor :pass
  
  def initialize(app, options={})
    @app = app
    @find_user_by = options[:find_user_by] || lambda { |*| nil }
    @authenticate_with = options[:authenticate_with] || lambda { |*| puts "WARNING: default auth will deny everyone!"; false }
    @pass = [options[:pass] || []].flatten
  end
  
  def find_user(username, env)
    find_user_by.call(username, env)
  end
  
  def bypass_authentication?(env)
    self.pass.any? { |pass_rule| pass_request_authentication?(pass_rule, env) }
  end
  
  def request_with_basic_auth(env)
    if bypass_authentication?(env)
      return app.call(env)
    end
    
    auth_request =  Rack::Auth::Basic::Request.new(env)   
    return unauthorized unless auth_request.provided?
    return bad_request unless auth_request.basic?
    user = find_user(auth_request.username, env)
    authorized = user && authenticate_with.call(user, auth_request)
    
    if authorized
      env['REMOTE_USER'] = auth_request.username
      env['integrity.current_user'] = user
      return app.call(env)
    else
      return unauthorized
    end
  end
  
  def call(env)
    request_with_basic_auth(env)
  end
  
  private
  def bad_request
    return [ 400,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => '0' },
      []
    ]
  end
  
  def unauthorized(www_authenticate = %(Basic realm=""))
    return [ 401,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => www_authenticate.to_s },
      []
    ]
  end
  
  def pass_request_authentication?(rule, env)
    puts rule.to_s
    case rule
    when Regexp
      lambda { |e| 
        [e['REQUEST_METHOD'], e['PATH_INFO']].join(' ') =~ rule 
      }
    when Proc
      rule
    else
      lambda { |*| false }
    end.call(env)
  end
  
end