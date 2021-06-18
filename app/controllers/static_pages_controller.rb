class StaticPagesController < ApplicationController
  def home
    @uploaded_file = UploadedFile.new
  end

  def converted
    @uploaded_file = UploadedFile.find(params[:id])
  end
end
