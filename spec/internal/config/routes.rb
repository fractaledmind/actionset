# frozen_string_literal: true

Rails.application.routes.draw do
  resources :things do
    get 'ransack', on: :collection
  end
end
