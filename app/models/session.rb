class Session < ApplicationRecord
	has_many :uploaded_files

	before_validation :generate_session_token

	private

		def generate_session_token
			self.token = SecureRandom.urlsafe_base64
		end
end
