class ApplicationController < ActionController::Base
	before_action :check_session

	def check_session
		if cookies.permanent.signed[:ocr_session]
			@session = Session.find_by(token: cookies.permanent.signed[:ocr_session])
		else
			token = SecureRandom.urlsafe_base64
			cookies.permanent.signed[:ocr_session] = {
				value: token,
				httponly: true
			}
			@session = Session.create(token: token)
		end
	end
end
