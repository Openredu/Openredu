class DropPartnerEnvironmentAssociations < ActiveRecord::Migration
  def change
    drop_table :partner_environment_associations
  end
end
