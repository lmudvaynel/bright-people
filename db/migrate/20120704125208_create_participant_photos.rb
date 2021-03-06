class CreateParticipantPhotos < ActiveRecord::Migration
  def change
    create_table :participant_photos do |t|
      t.string :attach_file_name, :attach_content_type
      t.integer :attach_file_size, :participant_id
      t.datetime :attach_updated_at

      t.timestamps
    end
  end
end
