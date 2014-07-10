class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :method, :null => false
      t.string :input
      t.string :output

      t.timestamps
    end
  end
end
