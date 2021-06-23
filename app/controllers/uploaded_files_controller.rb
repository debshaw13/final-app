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
      folder = SecureRandom.urlsafe_base64
      SystemCall.call('mkdir ' + folder)

      s3_downloader(ENV['AWS_BUCKET'], @uploaded_file.file.key, Rails.root.to_s + '/' + folder + '/' + 'input' + '.pdf')
      path = Rails.root.to_s + '/' + folder + '/' + 'input.pdf'
      folder_path = Rails.root.to_s + '/' + folder

      language = case @uploaded_file.ocr_language_id
        when 1
          'ara'
        when 2
          'chi_sim'
        when 3
          'chi_tra'
        when 4
          'deu'
        when 5
          'eng'
        when 6
          'fra'
        when 7
          'hin'
        when 8
          'ind'
        when 9
          'ita'
        when 10
          'jpn'
        when 11
          'kor'
        when 12
          'por'
        when 13
          'rus'
        when 14
          'spa'
        when 15
          'tur'
      end

      #@progress = 30
      SystemCall.call('pdftoppm -r 300 -gray -tiff ' + folder_path + '/input.pdf ' + folder_path + '/image_file')
      #@progress = 50
      SystemCall.call('for f in ' + folder_path + '/*.tif;do tesseract -l ' + language + ' -c textonly_pdf=1 "$f" ' + folder_path +'/"$(basename "$f" .tif)" pdf;done')
      #@progress = 70
      SystemCall.call('rm ' + folder_path + '/*.tif')
      #@progress = 80
      SystemCall.call('qpdf --empty --pages ' + folder_path + '/*.pdf -- ' + folder_path + '/merged.pdf')
      #@progress = 90
      SystemCall.call('qpdf ' + path + ' --underlay ' + folder_path + '/merged.pdf -- ' + folder_path + '/output.pdf')
      #@progress = 100
      puts SystemCall.call('ls ' + folder_path)

      @uploaded_file.file.attach(io: File.open(folder_path + "/output.pdf"), filename: @uploaded_file.file.filename )
      SystemCall.call('rm -r ' + folder_path)
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
