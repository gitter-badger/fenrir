class ImagesController < ApplicationController
  def serve
    path = "#{Rails.root.to_s}/app/assets/images/#{params[:filename]}.jpg"

    send_file( path,
      :disposition => 'inline',
      :type => 'image/jpeg',
      :x_sendfile => true )
  end
end