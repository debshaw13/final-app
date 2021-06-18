class UploadedFilesController < ApplicationController

  def create
    if (!current_user and @session.count < 3) or (current_user and @session.login_count < 3) or (current_user and current_user.subscribed?)
      @uploaded_file = UploadedFile.create(uploaded_file_params)
      @uploaded_file.file.attach(params[:uploaded_file][:file])
      @uploaded_file.session_id = @session.id
      @uploaded_file.user_id = current_user.id if current_user

      if @uploaded_file.save
        if current_user and !current_user.subscribed?
          @session.increment(:login_count).save
        elsif !current_user
          @session.increment(:count).save
        end

        #Conversion process
        path = ActiveStorage::Blob.service.send(:path_for, @uploaded_file.file.key)
        folder = SecureRandom.urlsafe_base64
        SystemCall.call('mkdir ' + folder)

        SystemCall.call('pdftoppm -tiff ' + path + ' ' + folder + '/image_file')
        SystemCall.call('for f in ' + folder + '/*.tif;do tesseract -c textonly_pdf=1 "$f" ' + folder +'/"$(basename "$f" .tif)" pdf;done')
        SystemCall.call('rm ' + folder + '/*.tif')
        SystemCall.call('qpdf --empty --pages ' + folder + '/*.pdf -- ' + folder + '/merged.pdf')
        SystemCall.call('qpdf ' + path + ' --underlay ' + folder + '/merged.pdf -- ' + folder + '/output.pdf')
        @uploaded_file.file.attach(io: File.open("#{Rails.root}/" + folder + "/output.pdf"), filename: @uploaded_file.file.filename )
        SystemCall.call('rm -r ' + folder)

        redirect_to converted_path(@uploaded_file.id)
      else
        render "static_pages/home"
      end
    else
      @uploaded_file = UploadedFile.new
      if current_user
        @uploaded_file.errors.add(:base, "You are out of free credits. Please upgrade to a subscription.")
      else
        @uploaded_file.errors.add(:base, "You are out of free credits. Please sign up for an account.")
      end
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
