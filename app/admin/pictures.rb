# -*- coding: utf-8 -*-
ActiveAdmin.register Picture do
  menu label: 'Картинки'

  filter :caption

  index do
    id_column
    column "Фотография" do |picture|
        link_to image_tag(picture.picture.url(:thumb), alt: picture.caption), admin_picture_path(picture)
    end
    column :caption
    column "URL картинки" do |picture|
      span class: 'get_host_url' do
        picture.picture.url(:original, timestamp: false)
      end
    end
    default_actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Основное' do
      f.input :caption
      f.input :picture, as: :file,
                      hint: f.template.image_tag(f.object.picture.url(:medium))
    end
    f.buttons
  end

  show do
    attributes_table_for resource do
      row :caption
      row "URL картинки" do
        span class: 'get_host_url' do
          resource.picture.url(:original, timestamp: false)
        end
      end
    end

    panel 'Картинка' do
      image_tag(picture.picture.url)
    end
  end
end
