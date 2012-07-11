class AddDataPageMission < ActiveRecord::Migration
  def up
    if Page.find_by_permalink('mission')
      puts "I can't create 'mission' page, becouse it's already exist"
      return
    else
      if Page.create(permalink: 'mission', text: '<h1>Change this text in Admin Panel!!!</h1>' )
        puts "Create page 'mission' success"
      else
        puts "ERROR!!! Something wrong with create page 'mission'"
      end
    end
  end

  def down
    return unless page = Page.find_by_permalink('mission')
    page.destroy
  end
end
