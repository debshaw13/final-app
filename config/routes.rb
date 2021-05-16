Rails.application.routes.draw do
	root 'static_pages#home'

	get 'converted/:id' 							=> 'static_pages#converted', as: "converted"
	mount PdfjsViewer::Rails::Engine 	=> '/pdfjs', as: "pdfjs"

	resources :uploaded_files, only: [:create]
end