class AddAssignToAndRenameUserNameInTickets < ActiveRecord::Migration[8.1]
  def change
    # Add new column
    add_column :tickets, :assign_to, :string

    # Rename column
    rename_column :tickets, :user_name, :requestor
  end
end
