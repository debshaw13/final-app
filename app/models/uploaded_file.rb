class UploadedFile < ApplicationRecord
  has_one_attached  :file
  belongs_to :ocr_language
  belongs_to :session

  validates :file, :presence => true

  def self.s3_downloader(bucketName, key, localPath)
    s3 = Aws::S3::Resource.new(
      access_key_id:     ENV['AWS_S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_S3_SECRET_ACCESS_KEY'],
      region:            ENV['AWS_REGION']
    )

    sourceObj = s3.bucket(bucketName).object(key)

    sourceObj.get(response_target: localPath)
    puts "s3://#{bucketName}/#{key} has been downloaded to #{localPath}"
  end
end
