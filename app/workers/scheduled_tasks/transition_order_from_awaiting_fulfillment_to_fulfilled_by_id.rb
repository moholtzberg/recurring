module ScheduledTasks
  
  require 'sidekiq-scheduler'

  class TransitionOrderFromAwaitingFulfillmentToFulfilledById
    include Sidekiq::Worker
    include JobLogger

    def perform(order_id)
      puts order_id
      order = Order.find_by(:id => order_id)
      puts order.inspect
      
      if (order.quantity == order.quantity_shipped) and (order.quantity != order.quantity_fulfilled)
        puts "we can invoice"
        Order.transaction do 
      
          if order.create_full_invoice
            OrderMailer.invoice_notification(order.id).deliver_later
          end
        
        end
      
      end
    
    end
  
  end
  
end