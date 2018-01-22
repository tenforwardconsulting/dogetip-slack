require 'bitcoin-client'
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance info deposit tip withdraw networkinfo)
  def initialize(slack_params)
    text = slack_params['text']
    @params = text.split(/\s+/)
    raise "WACK" unless @params.shift == slack_params['trigger_word']
    @user_name = slack_params['user_name']
    @user_id = slack_params['user_id']
    @action = @params.shift
    @result = {}
  end

  def perform
    if ACTIONS.include?(@action)
      self.send("#{@action}".to_sym)
    else
      raise "such error no command wow"
    end
  end

  def client
    @client ||= Bitcoin::Client.local('dogecoin')
  end

  def balance
    balance = client.getbalance(@user_id)
    @result[:text] = "@#{@user_name} such balance #{balance}Ð"
    if (balance > 0)
      @result[:text] += " many coin"
    elsif balance > 1000
      @result[:text] += " very wealth!"
      @result[:icon_emoji] = ":moneybag:"
    end

  end

  def deposit
    @result[:text] = "so deposit #{user_address(@user_id)} many address"
  end

  def tip
    user = @params.shift
    raise "pls say tip @username amount" unless user =~ /<@(U.+)>/

    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "such generous! <@#{@user_id}> => <@#{target_user}> #{@amount}Ð"
    @result[:attachments] = [{
      fallback:"<@#{@user_id}> => <@#{target_user}> #{@amount}Ð",
      color: "good",
      fields: [{
        title: "such tipping #{@amount}Ð wow!",
        value: "http://dogechain.info/tx/#{tx}",
        short: false
      },{
        title: "generous shibe",
        value: "<@#{@user_id}>",
        short: true
      },{
        title: "lucky shibe",
        value: "<@#{target_user}>",
        short: true
      }]
    }]

    @result[:text] += " (<http://dogechain.info/tx/#{tx}|such blockchain>)"
  end

  alias :":dogecoin:" :tip

  def withdraw
    address = @params.shift
    set_amount
    tx = client.sendfrom @user_id, address, @amount
    @result[:text] = "such stingy <@#{@user_id}> => #{address} #{@amount}Ð (#{tx})"
    @result[:icon_emoji] = ":shit:"
  end

  def networkinfo
    info = client.getinfo
    @result[:text] = info.to_s
    @result[:icon_emoji] = ":bar_chart:"
  end

  private

  def set_amount
    @amount = @params.shift
    randomize_amount if (@amount == "random")
    @amount = @amount.to_i

    raise "so poor not money many sorry" unless available_balance >= @amount + 1
    raise "such stupid no purpose" if @amount < 1
  end

  def randomize_amount
    lower = [1, @params.shift.to_i].min
    upper = [@params.shift.to_i, available_balance].max
    @amount = rand(lower..upper)
    @result[:icon_emoji] = ":black_joker:"
  end

  def available_balance
     client.getbalance(@user_id)
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
