require 'sidekiq-scheduler'

class SendCustomerStatements  
  include Sidekiq::Worker
  include JobLogger

  def perform
    Customer.where(active: true).each do |customer|
      if customer.outstansing_invoices > 0
        ScheduledTasks::SendCustomerStatmentByAccountId.perform_async(customer.id)
      end
    end
  end
  
end
