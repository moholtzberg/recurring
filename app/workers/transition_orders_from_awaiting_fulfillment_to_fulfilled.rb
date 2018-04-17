require 'sidekiq-scheduler'

class TransitionOrdersFromAwaitingFulfillmentToFulfilled
  include Sidekiq::Worker
  include JobLogger

  def perform(appliable_type, appliable_id)
    puts "---> #{appliable_type}"
    puts "---> #{appliable_id}"
    account_ids = []
    if appliable_type.downcase  == "account"
      puts "--- 1 #{Account.find_by(id: appliable_id)&.name}"
      account_ids.push appliable_id
    elsif appliable_type.downcase == "group"
      puts "--- 3 #{Group.find_by(id: appliable_id)&.name}" 
      account_ids.push Group.find(appliable_id)&.account_ids
    else
      account_ids.push nil
    end
    puts account_ids.inspect
    orders = Order.where(account_id: account_ids, state: "awaiting_fulfillment")
    orders.each do |ord|
      puts "#{ord.state} - #{ord.number}"
    end
    #o.order_line_items.each {|l| puts (l.price == Price.where(appliable_id: o.account&.group_id, item_id: l.item_id).last.price) }
  end

end