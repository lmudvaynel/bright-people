FileUtils.rm_rf Rails.root.join('public/system/interviews')

photos = Dir.glob(Rails.root.join('db/sample/files/articles', '*'))

Interview.all.each do |interview|
  interview.update_attribute(:picture, File.new(photos.shuffle.first))
  interview.update_attribute(:author_id, User.all.shuffle.first.id)
end
