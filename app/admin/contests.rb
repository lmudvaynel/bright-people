# -*- coding: utf-8 -*-
ActiveAdmin.register Contest do
  menu label: "Конкурсы", :parent => "Конкурсы"

  filter :name
  filter :category

  index do
    id_column
    column :name
    column :active
    column :category
    default_actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Основное' do
      f.input :name
      f.input :active
      f.input :started_at
      f.input :ended_at
      f.input :category, include_blank: false
      f.input :description, input_html: {size: 10}
      f.input :rules, input_html: {size: 10}
      f.input :picture, as: :file, hint: f.template.image_tag(f.object.picture.url(:medium))
    end
    f.buttons
  end

  show do
    attributes_table :id, :name, :description, :rules, :started_at, :ended_at, :category

    panel 'Фотография' do
      image_tag(contest.picture.url)
    end
  end
end
