require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :error, :action, :user_name
  ACTIONS = %w(balance info deposit)
  def initialize(slack_params)
    text = slack_params['text']
    @params = text.split(/\s+/)
    raise "WACK" unless @params.shift == slack_params['trigger_word']
    @user_name = slack_params['user_name']
    @user_id = slack_params['user_id']
    @action = @params.shift  
  end

  def perform
    if ACTIONS.include?(@action)
      self.send("#{@action}".to_sym)
    else
      @result = "Unknown action"
      @error = true
    end
  end

  def client
    @client ||= Bitcoin::Client.local('dogecoin')
  end

  def balance
    balance = client.getbalance(@user_id)
    @result = "Balance for #{@user_name} is #{balance}"
  end

  def info
    "Your deposit address is #{user_address}"
  end


  private 

  def user_address
     existing = client.getaddressesbyaccount(@user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(@user_id)
    end
  end

end