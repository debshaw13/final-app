Rails.application.routes.draw do
	root 'static_pages#home'
	get 'converted/:id' 				=> 'static_pages#converted', as: "converted"
	resources :uploaded_files, only: [:create]
	mount PdfjsViewer::Rails::Engine 	=> '/pdfjs', as: "pdfjs"
end