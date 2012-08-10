require 'spec_helper'

describe GalleryPhoto do
  before(:each) do
    FileUtils.rm_rf Rails.root.join('public/system/gallery_photos')
    FileUtils.rm_rf Rails.root.join('public/arhives')
  end

  it "Save exif datatime" do
    file = File.new(Rails.root.join('spec/files/pics_032.jpg'))
    photo = FactoryGirl.create(:gallery_photo, photo: file)
    photo.shot_date.should == Time.zone.parse('2011-11-02 10:59:58 +0400')
  end

  it "Should be not save duplicate" do
    file = File.new(Rails.root.join('spec/files/pics_032.jpg'))
    FactoryGirl.create(:gallery_photo, photo: file)
    photo = FactoryGirl.build(:gallery_photo, photo: file)
    photo.should have(2).error_on(:photo_fingerprint)
  end

  describe "Creating photo archive" do
    it "Should create public/arhives by first time" do
      photo = FactoryGirl.create(:gallery_photo)
      GalleryPhoto.create_archive(photo)
      File.directory?(Rails.root.join('public/arhives')).should == true
    end

    it "Should create unic folder for archive" do
      photo = FactoryGirl.create(:gallery_photo)
      GalleryPhoto.create_archive(photo)
      File.directory?(Rails.root.join('public/arhives')).should == true
    end

    it "Should create zip artiche with random name" do
      photo = FactoryGirl.create(:gallery_photo)
      GalleryPhoto.create_archive(photo).should =~ /\w{24}\.zip$/
    end

    it "Should create zip arhive with 2 files" do
      photo = FactoryGirl.create(:gallery_photo)
      photo2 = FactoryGirl.create(:gallery_photo, photo: File.new(Rails.root.join('spec/files/pics_032.jpg')))
      arhive = GalleryPhoto.create_archive([photo, photo2])
      File.size(arhive).to_s.should =~ /988\d+/
    end
  end

end
