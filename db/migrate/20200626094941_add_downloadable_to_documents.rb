class AddDownloadableToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :downloadable, :boolean, null: false, default: false
  end
end
