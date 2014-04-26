require 'bitcoin-client'
require './coin_config/dogecoin.rb'
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
      raise Dogecoin::PERFORM_ERROR
    end
  end

  def client
    @client ||= Bitcoin::Client.local(Dogecoin::NETWORK)
  end

  def balance
    puts "#{network.upcase}#{::BALANCE_REPLY_PRETEXT}"
    balance = client.getbalance(@user_id)
    @result[:text] = "@#{@user_name} #{Dogecoin::BALANCE_REPLY_PRETEXT} #{balance}#{Dogecoin::CURRENCY_ICON}"
    if balance > Dogecoin::WEALTHY_UPPER_BOUND
      @result[:text] += Dogecoin::WEALTHY_UPPER_BOUND_POSTTEXT
      @result[:icon_emoji] = Dogecoin::WEALTHY_UPPER_BOUND_EMOJI
    elsif balance > 0 && balance < Dogecoin::WEALTHY_UPPER_BOUND
      @result[:text] += Dogecoin::BALANCE_REPLY_POSTTEXT
    end

  end

  def deposit
    @result[:text] = "#{Dogecoin::DEPOSIT_PRETEXT} #{user_address(@user_id)} #{Dogecoin::DEPOSIT_POSTTEXT}"
  end

  def tip
    user = @params.shift
    raise Dogecoin::TIP_ERROR_TEXT unless user =~ /<@(U.+)>/

    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "#{Dogecoin::TIP_PRETEXT} <@#{@user_id}> => <@#{target_user}> #{@amount}#{Dogecoin::CURRENCY_ICON}"
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
    
    @result[:text] += " (<#{Dogecoin::TIP_POSTTEXT1}#{tx}#{Dogecoin::TIP_POSTTEXT2}>)"
  end

  alias :":dogecoin:" :tip

  def withdraw
    address = @params.shift
    set_amount
    tx = client.sendfrom @user_id, address, @amount
    @result[:text] = "#{Dogecoin::WITHDRAW_TEXT} <@#{@user_id}> => #{address} #{@amount}#{Dogecoin::CURRENCY_ICON} (#{tx})"
    @result[:icon_emoji] = Dogecoin::WITHDRAW_ICON
  end

  def networkinfo
    info = client.getinfo
    @result[:text] = info.to_s
    @result[:icon_emoji] = Dogecoin::NETWORKINFO_ICON
  end

  private

  def set_amount
    amount = @params.shift
    @amount = amount.to_i
    randomize_amount if (@amount == "random")
    
    raise Dogecoin::TOO_POOR_TEXT unless available_balance >= @amount + 1
    raise Dogecoin::NO_PURPOSE_LOWER_BOUND_TEXT if @amount < Dogecoin::NO_PURPOSE_LOWER_BOUND
  end

  def randomize_amount
    lower = [1, @params.shift.to_i].min
    upper = [@params.shift.to_i, available_balance].max
    @amount = rand(lower..upper)
    @result[:icon_emoji] = Dogecoin::RANDOMIZED_EMOJI
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
