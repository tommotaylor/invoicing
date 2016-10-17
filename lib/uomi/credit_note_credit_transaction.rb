module Uomi
  class CreditNoteCreditTransaction < ActiveRecord::Base
    belongs_to :credit_note
    belongs_to :cn_transaction, class_name: 'Transaction'
  end
end
