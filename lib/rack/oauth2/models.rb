require "mongo"
require "openssl"
require "rack/oauth2/server/errors"
require "rack/oauth2/server/utils"

module Rack
  module OAuth2
    class Server

      class << self
        # Create new instance of the klass and populate its attributes.
        def new_instance(klass, fields)
          ::Rails::Railtie::Rails.logger.debug "new_instance"
          ::Rails::Railtie::Rails.logger.debug "1. fields = "+fields.inspect.to_s
          return unless fields
          instance = klass.new
          ::Rails::Railtie::Rails.logger.debug "klass = "+klass.inspect.to_s
          fields = fields.first if fields.kind_of? Moped::Query
          ::Rails::Railtie::Rails.logger.debug "2. fields = "+fields.inspect.to_s
          return if fields.nil?
          fields.each do |name, value|
            ::Rails::Railtie::Rails.logger.debug "name = "+name.to_s
            instance.instance_variable_set :"@#{name}", value
          end
          ::Rails::Railtie::Rails.logger.debug "instance = "+instance.to_s
          instance
        end

        # Long, random and hexy.
        def secure_random
          OpenSSL::Random.random_bytes(32).unpack("H*")[0]
        end
        
        # @private
        def create_indexes(&block)
          if block
            @create_indexes ||= []
            @create_indexes << block
          elsif @create_indexes
            @create_indexes.each do |block|
              block.call
            end
            @create_indexes = nil
          end
        end
 
        # A Mongo::DB object.
        def database
          @database ||= Server.options.database
          raise "No database Configured. You must configure it using Server.options.database = Mongo::Connection.new()[db_name]" unless @database
          #raise "You set Server.database to #{Server.database.class}, should be a Mongo::DB object" unless Mongo::DB === @database
          @database
        end
      end
 
    end
  end
end


require "rack/oauth2/models/client"
require "rack/oauth2/models/auth_request"
require "rack/oauth2/models/access_grant"
require "rack/oauth2/models/access_token"
require "rack/oauth2/models/issuer"
