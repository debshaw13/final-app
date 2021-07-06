Rails.application.routes.draw do
	root 'static_pages#home'
	get 'converted/:id' 				=> 'static_pages#converted', as: "converted"
	get 'checkout'	 						=> 'checkouts#show'
	get 'billing'								=> 'billing#show'

	resources :uploaded_files, only: [:create, :destroy] do
		member do
			get 'progress'
		end
	end

	resources :converted_files, only: [:create, :destroy] do
	end

	mount PdfjsViewer::Rails::Engine 	=> '/pdfjs', as: "pdfjs"

	devise_for :users, controllers: { registrations: 'users/registrations' }
end
