class UploadedFilesController < ApplicationController

  def create
    if eligible_user
      @uploaded_file = UploadedFile.create(uploaded_file_params)
      @uploaded_file.file.attach(params[:uploaded_file][:file])
      set_session_and_user_id

      if @uploaded_file.save
        increment_count
        @converted_file = ConvertedFile.create(uploaded_file_id: @uploaded_file.id,ocr_language_id: @uploaded_file.ocr_language_id,session_id: @uploaded_file.session_id,user_id: @uploaded_file.user_id)

        MyWorker.perform_async(@uploaded_file.id)

        redirect_to converted_path(@converted_file.id)
      else
        render "static_pages/home"
      end
    else
      @uploaded_file = UploadedFile.new
      no_credits_message
      render "static_pages/home"
    end
  end

  def progress
    @uploaded_file = UploadedFile.find(params[:id])
    @converted_file = ConvertedFile.find_by(uploaded_file_id: @uploaded_file.id)
    if @uploaded_file.progress == 95 && @converted_file.file.attached?
      @uploaded_file.update(progress: 100)
    end
  end

  private

    def uploaded_file_params
      params.require(:uploaded_file).permit(:file, :ocr_language_id)
    end

    def eligible_user
      (!current_user and @session.count < 3) or (current_user and @session.login_count < 3) or (current_user and current_user.subscribed?)
    end

    def set_session_and_user_id
      @uploaded_file.session_id = @session.id
      @uploaded_file.user_id = current_user.id if current_user
    end

    def increment_count
      if current_user and !current_user.subscribed?
        @session.increment(:login_count).save
      elsif !current_user
        @session.increment(:count).save
      end
    end

    def no_credits_message
      if current_user
        @uploaded_file.errors.add(:base, "You are out of free credits. Please upgrade to a subscription.")
      else
        @uploaded_file.errors.add(:base, "You are out of free credits. Please sign up for an account.")
      end
    end

end
