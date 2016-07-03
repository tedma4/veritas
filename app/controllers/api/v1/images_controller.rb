class Api::V1::ImagesController < ApplicationController
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
    @image.save
    ensure
      clean_tempfile
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
    the_params = params.require(:image).permit(:attachment, :latitude, :longitude)#:user_id
    the_params[:attachment] = parse_image_data(the_params[:attachment]) if the_params[:attachment]
    the_params.to_h
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def parse_image_data(base64_image)
    filename = "upload-image"
    # in_content_type, encoding, string = base64_image.split(/[:;,]/)[0..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(base64_image)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
                                               tempfile: @tempfile,
                                               content_type: content_type,
                                               filename: filename
                                           })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
  
  # could be improve and include into concerns
  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  # def find_imageable
  #   params.each do |name, value|
  #     return @imageable = $1.classify.constantize.find(value) if name =~ /(.+)_id$/
  #   end
  # end
end