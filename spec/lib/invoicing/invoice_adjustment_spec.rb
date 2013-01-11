require 'spec_helper'

describe Invoicing::InvoiceAdjustment do
  include Helpers
  
  before(:each) do
    tear_it_down

    buyer = Invoicing::DebitTransaction.create!
    
    @invoice = Invoicing::generate do
      to buyer

      line_item description: "Line Item 1", amount: 1101
      line_item description: "Line Item 2", amount: 5097
      line_item description: "Line Item 3", amount: 1714

      payment_reference "REF123"
      decorate_with tenant_name: "Peter"
    end
  end

  context "adjusting a draft invoice" do
  
    it "should allow the due date to be updated" do
      @invoice.adjust do
        due Date.tomorrow
      end
    end

    it "should allow the buyer to be changed" do
      new_buyer = Invoicing::DebitTransaction.create!

      @invoice.adjust do
        to new_buyer
      end

      @invoice.buyer.buyerable.should == new_buyer
    end

    it "should allow a payment references to be added" do
      @invoice.adjust do
        add_payment_reference "NEWREF123"
      end

      @invoice.payment_references.count.should == 2
    end

    it "should allow a payment references to be removed" do
      @invoice.adjust do
        remove_payment_reference @invoice.payment_references.last
      end

      @invoice.payment_references.count.should == 0
    end

    it "should allow the invoice decorator to be updated" do
      decorations = {tenant_name: "Bob"}

      @invoice.adjust do
        decorate_with decorations
      end

      @invoice.decorator.data.should == decorations
    end

    it "should allow line items to be added" do
      item_to_invoice = @invoice.extend(Invoicing::Invoiceable)
      @invoice.line_items.count.should == 3

      @invoice.adjust do
        add_line_item(item_to_invoice)
      end

      @invoice.line_items.count.should == 4
      @invoice.total.should == 7912
    end

    it "should allow line items to be removed" do
      @invoice.line_items.count.should == 3

      @invoice.adjust do
        remove_line_item(@invoice.line_items.first)
      end

      @invoice.line_items.count.should == 2
      @invoice.total.should == 6811
    end

  end

  context "adjusting an issued invoice" do

    it "should raise an exception" do
      @invoice.issue!

      expect {
        @invoice.adjust do
          due Date.tomorrow
        end
      }.to raise_error(Invoicing::CannotAdjustIssuedDocument)
    end

  end

end