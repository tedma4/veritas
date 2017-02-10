class AreaMailer < ApplicationMailer

	def send_farewell(user, area, area_watcher)
    @user = user
    @area = area
    @area_watcher = area_watcher
    mail(to: @user.email, subject: "GoodBye from #{area.title}")
  end 
   
  def send_hello(user, area)
    @user = user
    @area =  area
    mail(to: @user.email, subject: "Welcome to #{area.title}")
  end

end