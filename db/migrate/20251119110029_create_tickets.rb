class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :ticket_id
      t.string :description
      t.string :requestor
      t.string :status
      t.string :source
      t.string :priority

      t.timestamps
    end
  end
end
