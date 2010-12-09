module Integrity
  class SimpleUser
    include DataMapper::Resource

    def self.default_repository_name=(repo_name)
      @default_repo_name = repo_name
    end

    def self.default_repository_name 
      @default_repo_name || :user_database
    end

    property :username, String, :key => true, :required => true
    property :password, String, :required => true

    def authenticate(challenge)
      challenge == self.password
    end
  end
end