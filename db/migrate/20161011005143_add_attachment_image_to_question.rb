class AddAttachmentImageToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :image_file_name, :string
    add_column :questions, :image_content_type, :string
    add_column :questions, :image_file_size, :integer
    add_column :questions, :image_updated_at, :datetime
  end

  def self.down
    remove_column :questions, :image_file_name
    remove_column :questions, :image_content_type
    remove_column :questions, :image_file_size
    remove_column :questions, :image_updated_at
  end
end
