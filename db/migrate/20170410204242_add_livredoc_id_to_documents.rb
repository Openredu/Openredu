class AddLivredocIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :livredoc_id, :integer
  end
end
