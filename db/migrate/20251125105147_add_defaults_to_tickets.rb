class AddDefaultsToTickets < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tickets, :status, "open"
    change_column_default :tickets, :source, "email"
  end
end
