class UploadedFile < ApplicationRecord
	has_one_attached	:file
end
