class AddRecoveryTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :recovery_token, :string
  end
end
