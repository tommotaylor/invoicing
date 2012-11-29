module Invoicing
  class LineItem < ActiveRecord::Base
    belongs_to :invoice
    belongs_to :invoiceable, polymorphic: true

    validates :amount, numericality: {greater_than_or_equal_to: 0}, presence: true
  
    def net_amount
      amount - tax
    end
  end
end