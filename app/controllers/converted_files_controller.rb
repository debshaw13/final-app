class ConvertedFilesController < ApplicationController
  def destroy
    @converted_file = ConvertedFile.find(params[:id])
    @uploaded_file = UploadedFile.find(@converted_file.uploaded_file_id)
    @converted_file.destroy
    @uploaded_file.destroy
    redirect_to root_path
  end
end
