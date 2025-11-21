class AddAuthFieldsAndChangeRoleInUsers < ActiveRecord::Migration[8.1]
  def change
    # Add refresh_token column only if not already present
    add_column :users, :refresh_token, :string unless column_exists?(:users, :refresh_token)

    # Add index only if it does not exist
    add_index :users, :refresh_token unless index_exists?(:users, :refresh_token)

    # Update role column
    change_column :users, :role, :string, default: "consumer", null: false
  end
end
