class CreateScrollTests < ActiveRecord::Migration
  def change
    create_table :scroll_tests do |t|
      t.string :title
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
