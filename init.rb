$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

#require ".bundle/environment"
require "integrity"

# Uncomment as appropriate for the notifier you want to use
# = Email
require "smtp-tls"
require "integrity/notifier/email"

# = IRC
# require "integrity/notifier/irc"
# = Campfire
# require "integrity/notifier/campfire"
# = TCP
# require "integrity/notifier/tcp"
# = HTTP
# require "integrity/notifier/http"
# = Notifo
# require "integrity/notifier/notifo"
# = AMQP
# require "integrity/notifier/amqp"

Integrity.configure do |c|
  c.database      =  "sqlite3:integrity.db"
  c.user_database =  "yaml:users"
  c.directory     =  "builds"
  c.base_url      =  "https://ci.animoto.com"
  c.log           =  "integrity.log"
  c.github_token  =  Integrity.read_github_token(File.expand_path("../../github_token",__FILE__))
  c.build_all     = false
  c.builder       = :threaded, 5
end
