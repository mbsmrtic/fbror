class CreateHdrQuotes < ActiveRecord::Migration
  def change
    create_table :hdr_quotes do |t|
      t.string :quote
    end
  end
end
