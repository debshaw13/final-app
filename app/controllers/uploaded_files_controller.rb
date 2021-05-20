class UploadedFilesController < ApplicationController
	before_action :increment_count, only: [:create]

	def create
		if @session.count < 4
			@uploaded_file = UploadedFile.create(uploaded_file_params)
			@uploaded_file.file.attach(params[:uploaded_file][:file])
			@uploaded_file.session_id = @session.id

			if @uploaded_file.save
				redirect_to converted_path(@uploaded_file.id)
			else
				@session.decrement(:count).save
				render "static_pages/home"
			end
		else
			@uploaded_file = UploadedFile.new
			@session.decrement(:count).save
			@uploaded_file.errors.add(:base, "You are out of free credits. Please sign up for an account.")
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

		def increment_count
			if @session.count < 4
				@session.increment(:count).save
			end
		end

end
