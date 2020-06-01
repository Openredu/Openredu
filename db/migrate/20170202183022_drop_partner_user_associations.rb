class DropPartnerUserAssociations < ActiveRecord::Migration
  def change
    drop_table :partner_user_associations
  end
end
