require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :error, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance info deposit tip)
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
      @result = "such error no command wow"
      @error = true
    end
  end

  def client
    @client ||= Bitcoin::Client.local('dogecoin')
  end

  def balance
    balance = client.getbalance(@user_id)
    @result = "@#{@user_name} such balance #{balance}Ð"
    @result += " many coin" if balance > 0
  end

  def deposit
    @result = "so deposit #{user_address(@user_id)} many address"
  end

  alias :":dogecoin:" :tip
  def tip
    user = @params.shift
    if user =~ /<@(U\d+)>/
      target_user = $1
      available_balance = client.getbalance(@user_id)
      amount = @params.shift
      @result = "such generous <@#{@user_id}> => <@#{target_user}> #{amount}Ð"
    else
      @error = true
      @result = "such error pls say tip @username amount"
    end
    
  end

  private 

  def user_address(user_id)
     existing = client.getaddressesbyaccount(user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(user_id)
    end
  end

end