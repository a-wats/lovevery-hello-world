Rails.application.routes.draw do
	root "hello#index"
	match "*path", to: "hello#index", via: :all
end
