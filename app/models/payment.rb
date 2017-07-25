class Payment < ActiveRecord::Base
  
  self.inheritance_column = :payment_type
  belongs_to :account
  belongs_to :payment_method
  has_many :order_payment_applications
  has_many :transactions
  accepts_nested_attributes_for :order_payment_applications

  validates :amount, :presence => true, :numericality => { greater_then: 0 }
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end

  def authorize
    true
  end

  def completed?
    if payment_type == "CheckPayment"
      success?
    elsif payment_type == "CreditCardPayment"
      success? && captured?
    end
  end
  
  def total_applications
    OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def applied_amount
    OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def unapplied_amount
    amount.to_d - OrderPaymentApplication.where(payment_id: self.id).map(&:applied_amount).sum.to_d
  end
  
  def number
    if payment_type == "CheckPayment"
      "CK# #{check_number}"
    elsif payment_type == "CreditCardPayment"
      "AUTH# #{authorization_code}"
    end
  end
  
end