module LocationExt
  extend ActiveSupport::Concern

  included do
    # OPTIMIZE: try to destroy this callback. But when I try update
    # location I have error aboud bad position
    after_save do
      if @new_coords
        x = @new_coords.split(',')[0].to_f
        y = @new_coords.split(',')[1].to_f
        @new_coords = nil
        self.update_attribute(:location, Point.from_x_y(x, y, 4326))
      end
    end

    attr_accessible :coords
  end

  def coords
    return '' unless self.location
    "#{self.location.x},#{self.location.y}"
  end

  def coords=(_coords)
    @new_coords = _coords
  end

end
