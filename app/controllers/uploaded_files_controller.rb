class UploadedFilesController < ApplicationController

	def create
		@uploaded_file = UploadedFile.create(uploaded_file_params)
		@uploaded_file.file.attach(params[:uploaded_file][:file])
		@uploaded_file.session_id = @session.id

		if @uploaded_file.save
			redirect_to converted_path(@uploaded_file.id)
		else
			render "static_pages/home"
		end
	end

  def destroy
    @uploaded_file = UploadedFile.find(params[:id])
    @uploaded_file.destroy

    redirect_to root_path
  end

	private

		def uploaded_file_params
			params.require(:uploaded_file).permit(:file, :ocr_language_id)
		end

end
