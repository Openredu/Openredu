# -*- encoding : utf-8 -*-
class AddCurrentToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :current, :boolean
    change_column_default :invoices, :current, false

    add_index "invoices", "current", :name => "index_invoices_on_current"

#    Invoice.reset_column_information
#    Invoice.update_all :current => false
    # Marca como atual o último plano do billable
#    Invoice.select('id, created_at, plan_id').all.group_by(&:plan).
#      each do |plan, invoices|
#        ActiveRecord::Base.record_timestamps = false
#        invoices_in_order = invoices.sort { |x, y| x.created_at <=> y.created_at }
#        current_invoice = invoices_in_order.last
#        current_invoice.update_attribute(:current, true)
#    end && nil
  end

  def self.down
    remove_column :invoices, :current
  end
end
