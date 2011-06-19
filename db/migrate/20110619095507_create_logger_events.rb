class CreateLoggerEvents < ActiveRecord::Migration
  def self.up
    create_table :logger_events do |t|
      t.belongs_to :person
      t.string :event_type, :description #, :loggable_type
      #t.integer :loggable_id
      t.boolean :visible
      t.timestamps
    end
  end

  def self.down
    drop_table :logger_events
  end
end
