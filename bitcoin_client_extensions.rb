module Bitcoin
  class Client
    def self.local
      return Bitcoin::Client.new(ENV['RPC_USER'], ENV['RPC_PASSWORD'],
        { host: '127.0.0.1', port: 8332, ssl: false} )
    end
  end
end
