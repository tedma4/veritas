class AreaMailer < ApplicationMailer

	def send_farewell(user, area, area_thingy)
    @user = user
    @area = area
    @area_thingy = area_thingy
    mail(to: @user.email, subject: "GoodBye from #{area.title}")
  end 
   
  def send_hello(user, area)
    @user = user
    @area =  area
    mail(to: @user.email, subject: "Welcome to #{area.title}")
  end

end