class SessionsController < ApplicationController

	def create
		@uploaded_file = UploadedFile.last

		if @uploaded_file
			session = @uploaded_file.sessions.create
			cookies.permanent.signed[:ocr_session_token] = {
				value: session.token,
				httponly: true
			}
		end
	end
end
