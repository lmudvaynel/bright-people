FileUtils.rm_rf Rails.root.join('public/system/photos')

photos = Dir.glob(Rails.root.join('db/sample/files/photos', '*'))

Expert.all.each do |expert|
  expert.update_attribute(:photo, File.new(photos.shuffle.first))
end
