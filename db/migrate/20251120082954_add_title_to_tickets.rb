class AddTitleToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :title, :string
  end
end
