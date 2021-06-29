class MyWorker
  include Sidekiq::Worker

  def perform(file)
    @uploaded_file = UploadedFile.find(file)

    folder = SecureRandom.urlsafe_base64
    process1 = SystemCall.call('mkdir ' + folder)
    puts process1.inspect

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
    process2 = SystemCall.call('pdftoppm -r 300 -gray -tiff ' + folder_path + '/input.pdf ' + folder_path + '/image_file')
    puts process2.inspect
    #@progress = 50
    process3 = SystemCall.call('for f in ' + folder_path + '/*.tif;do tesseract -l ' + language + ' -c textonly_pdf=1 "$f" ' + folder_path +'/"$(basename "$f" .tif)" pdf;done')
    puts process3.inspect
    #@progress = 70
    #process4 = SystemCall.call('rm ' + folder_path + '/*.tif')
    #puts process4.inspect
    #@progress = 80
    process5 = SystemCall.call('qpdf --empty --pages ' + folder_path + '/*.pdf -- ' + folder_path + '/merged.pdf')
    puts process5.inspect
    #@progress = 90
    process6 = SystemCall.call('qpdf ' + path + ' --underlay ' + folder_path + '/merged.pdf -- ' + folder_path + '/output.pdf')
    puts process6.inspect
    #@progress = 100
    process7 = puts SystemCall.call('ls ' + folder_path)
    puts process7.inspect

    @uploaded_file.file.attach(io: File.open(folder_path + "/output.pdf"), filename: @uploaded_file.file.filename )
    SystemCall.call('rm -r ' + folder_path)
    # block that will be retried in case of failure
  end
end
