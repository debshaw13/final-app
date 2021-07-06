class StaticPagesController < ApplicationController
  def home
    @uploaded_file = UploadedFile.new
  end

  def converted
    @converted_file = ConvertedFile.find(params[:id])
    @uploaded_file = UploadedFile.find(@converted_file.uploaded_file_id)
  end
end
