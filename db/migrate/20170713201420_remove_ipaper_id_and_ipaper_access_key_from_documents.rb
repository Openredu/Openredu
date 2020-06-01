class RemoveIpaperIdAndIpaperAccessKeyFromDocuments < ActiveRecord::Migration

  def up
    remove_column :documents, :ipaper_access_key
    remove_column :documents, :ipaper_id
  end
end
