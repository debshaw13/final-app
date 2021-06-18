class UploadedFilesController < ApplicationController

  def create
    if eligible_user
      @uploaded_file = UploadedFile.create(uploaded_file_params)
      @uploaded_file.file.attach(params[:uploaded_file][:file])
      set_session_and_user_id

      if @uploaded_file.save
        increment_count
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
      path = ActiveStorage::Blob.service.send(:path_for, @uploaded_file.file.key)
      folder = SecureRandom.urlsafe_base64

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

      puts language.inspect
      puts "SEEEE MEEE!!!!"

      SystemCall.call('mkdir ' + folder)
      SystemCall.call('pdftoppm -r 300 -gray -tiff ' + path + ' ' + folder + '/image_file')
      SystemCall.call('for f in ' + folder + '/*.tif;do tesseract -l ' + language + ' -c textonly_pdf=1 "$f" ' + folder +'/"$(basename "$f" .tif)" pdf;done')
      SystemCall.call('rm ' + folder + '/*.tif')
      SystemCall.call('qpdf --empty --pages ' + folder + '/*.pdf -- ' + folder + '/merged.pdf')
      SystemCall.call('qpdf ' + path + ' --underlay ' + folder + '/merged.pdf -- ' + folder + '/output.pdf')

      @uploaded_file.file.attach(io: File.open("#{Rails.root}/" + folder + "/output.pdf"), filename: @uploaded_file.file.filename )
      SystemCall.call('rm -r ' + folder)
    end

    def no_credits_message
      if current_user
        @uploaded_file.errors.add(:base, "You are out of free credits. Please upgrade to a subscription.")
      else
        @uploaded_file.errors.add(:base, "You are out of free credits. Please sign up for an account.")
      end
    end

end
