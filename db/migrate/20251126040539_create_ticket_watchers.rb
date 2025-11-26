class CreateTicketWatchers < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_watchers do |t|
      t.string :ticket_id
      t.integer :watcher_id

      t.timestamps
    end
  end
end
