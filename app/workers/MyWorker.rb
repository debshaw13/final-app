class MyWorker
  include Sidekiq::Worker

  def perform(file)
    @uploaded_file = UploadedFile.find(file)
    @converted_file = ConvertedFile.find_by(uploaded_file_id: @uploaded_file.id)
    @error = nil

    folder = SecureRandom.urlsafe_base64
    process1 = SystemCall.call('mkdir ' + folder)

    puts process1.error_result.inspect
    if process1.error_result != ""
      puts "Step 1"
      @error = process1.error_result
      raise
    end

    @uploaded_file.update(progress: 10)

    UploadedFile.s3_downloader(ENV['AWS_BUCKET'], @uploaded_file.file.key, Rails.root.to_s + '/' + folder + '/' + 'input' + '.pdf')
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

    @uploaded_file.update(progress: 30)
    process2 = SystemCall.call('pdftoppm -r 300 -gray -tiff ' + folder_path + '/input.pdf ' + folder_path + '/image_file')
    puts process2.error_result.inspect
    if process2.error_result != ""
      puts "Step 2"
      @error = process2.error_result
      raise
    end
    @uploaded_file.update(progress: 50)

    process3 = SystemCall.call('for f in ' + folder_path + '/*.tif;do tesseract -l ' + language + ' -c textonly_pdf=1 "$f" ' + folder_path +'/"$(basename "$f" .tif)" pdf;done')

    puts process3.error_result.inspect
    @uploaded_file.update(progress: 70)

    process4 = SystemCall.call('rm ' + folder_path + '/*.tif')

    puts process4.error_result.inspect
    if process4.error_result != ""
      puts "Step 4"
      @error = process4.error_result
      raise
    end
    @uploaded_file.update(progress: 80)

    process5 = SystemCall.call('qpdf --empty --pages ' + folder_path + '/*.pdf -- ' + folder_path + '/merged.pdf')
    puts process5.error_result.inspect
    if process5.error_result != ""
      puts "Step 5"
      @error = process5.error_result
      raise
    end
    @uploaded_file.update(progress: 90)

    process6 = SystemCall.call('qpdf ' + path + ' --underlay ' + folder_path + '/merged.pdf -- ' + folder_path + '/output.pdf')
    puts process6.error_result.inspect
    if process6.error_result != ""
      puts "Step 6"
      @error = process6.error_result
      raise
    end

    process7 = puts SystemCall.call('ls ' + folder_path)

    @converted_file.file.attach(io: File.open(folder_path + "/output.pdf"), filename: @uploaded_file.file.filename )
    SystemCall.call('rm -r ' + folder_path)
    @uploaded_file.update(progress: 95)
    # block that will be retried in case of failure
  rescue
    @uploaded_file.update(progress: 0)
    @converted_file.update(error: @error)
  end
end
