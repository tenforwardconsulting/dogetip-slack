module Bitcoin
  NETWORKS = {
    bitcoin: {
      port: 8332
    },
    dogecoin: {
      port: 22555
    },
    litecoin: {
      port: 9332
    }
  }

  class Client
    def self.local(network)
      puts "Connecting with user '#{ENV["RPC_USER"]}' '#{ENV["RPC_PASSWORD"]}'"
      return Bitcoin::Client.new(ENV['RPC_USER'], ENV['RPC_PASSWORD'],
        { :host => '127.0.0.1', :port => Bitcoin::NETWORKS[network.to_sym][:port], :ssl => false} )
    end
  end
end
