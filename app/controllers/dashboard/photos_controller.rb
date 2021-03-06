class Dashboard::PhotosController < Dashboard::BaseController
  def index
  end

  def my_photos
    @photos = GalleryPhoto.by_photograph(current_user).page(params[:page]).per(50)
  end

  def create
    @photo = GalleryPhoto.new(params[:gallery_photo])
    @photo.photo = params[:photo]
    @photo.user = current_user unless @photo.user.present?
    if @photo.save
      respond_to do |format|
        format.html {
          render :json => [@photo.to_jq_upload].to_json,
                 :content_type => 'text/html',
                 :layout => false
        }
        format.json {
          render :json => [@photo.to_jq_upload].to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  def destroy
    current_user.photos.find(params[:id]).destroy
    redirect_to my_photos_dashboard_photos_path
  end
end
