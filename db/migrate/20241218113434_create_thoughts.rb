# frozen_string_literal: true

class CreateThoughts < ActiveRecord::Migration[8.0]
  def change
    create_table :thoughts do |t|
      t.text :content
      t.timestamps
    end
  end
end
