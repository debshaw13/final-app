class UploadedFilesController < ApplicationController

  def create
    if eligible_user
      @uploaded_file = UploadedFile.create(uploaded_file_params)
      @uploaded_file.file.attach(params[:uploaded_file][:file])
      #@progress = @uploaded_file.progress
      #@progress = 10
      set_session_and_user_id

      if @uploaded_file.save
        increment_count
        #@progress = 20
        convert_file
        redirect_to converted_path(@uploaded_file.id)
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
    @progress = @uploaded_file.progress

    render partial: 'file_progress'
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

    def convert_file
      MyWorker.perform_async(@uploaded_file.id)
    end

    def s3_downloader(bucketName, key, localPath)
      s3 = Aws::S3::Resource.new(
        access_key_id:     ENV['AWS_S3_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_S3_SECRET_ACCESS_KEY'],
        region:            ENV['AWS_REGION']
      )

      sourceObj = s3.bucket(bucketName).object(key)

      sourceObj.get(response_target: localPath)
      puts "s3://#{bucketName}/#{key} has been downloaded to #{localPath}"
    end

    def no_credits_message
      if current_user
        @uploaded_file.errors.add(:base, "You are out of free credits. Please upgrade to a subscription.")
      else
        @uploaded_file.errors.add(:base, "You are out of free credits. Please sign up for an account.")
      end
    end

end
