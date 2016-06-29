class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :destroy]
   #:find_imageable

  def index
    @images = Image.all.order_by(id: :desc)
  end

  def show    
  end

  def new
    @image = Image.new    
  end
  
  def create
    # When Images need to be polymorphic, uncomment below
    # @imageable.attachments.create image_params
    # redirect_to @imageable
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
  
  def image_params
    params.require(:image).permit(:attachment)
  end

  def set_image
    @image = Image.find(params[:id])
  end
  
  # could be improve and include into concerns
  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  # def find_imageable
  #   params.each do |name, value|
  #     return @imageable = $1.classify.constantize.find(value) if name =~ /(.+)_id$/
  #   end
  # end
end