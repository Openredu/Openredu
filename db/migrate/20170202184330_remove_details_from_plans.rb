class RemoveDetailsFromPlans < ActiveRecord::Migration
  def up
    remove_column :plans, :price
    remove_column :plans, :billing_date
    remove_column :plans, :yearly_price
    remove_column :plans, :membership_fee
  end

  def down
    add_column :plans, :membership_fee, :decimal
    add_column :plans, :yearly_price, :decimal
    add_column :plans, :billing_date, :date
    add_column :plans, :price, :decimal
  end
end
