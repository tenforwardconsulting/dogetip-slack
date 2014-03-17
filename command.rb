require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :error, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance info deposit tip withdraw)
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


  def tip
    user = @params.shift
    raise "pls say tip @username amount" unless user =~ /<@(U.+)>/

    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result = "such generous <@#{@user_id}> => <@#{target_user}> #{@amount}Ð"
    
    @result += " (#{tx})"
  rescue StandardError => ex
    @error = true
    @result = "such error #{ex.message}"
  end
  alias :":dogecoin:" :tip

  def withdraw
    address = @params.shift
    set_amount
    tx = client.sendfrom @user_id, address, @amount
    @result = "such stingy <@#{@user_id}> => #{address} #{@amount}Ð (#{tx})"
  end

  private

  def set_amount
    available_balance = client.getbalance(@user_id)
    @amount = (@params.shift).to_i
    raise "so poor not money many sorry" unless available_balance > @amount + 1
    raise "such stupid no purpose" if @amount < 10
  end

  def user_address(user_id)
     existing = client.getaddressesbyaccount(user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(user_id)
    end
  end

end