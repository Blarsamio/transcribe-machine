class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.string :library_id
      t.string :guid
      t.string :title
      t.boolean :captions, default: false
      t.string :thumbnail_filename
      t.integer :views_count


      t.timestamps
    end
  end
end
