# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.belongs_to :thought
      t.timestamps
    end
  end
end
