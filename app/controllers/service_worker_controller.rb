class ServiceWorkerController < ApplicationController
    protect_from_forgery except: :service_worker

  def manifest
    render file: Rails.root.join("app/assets/config/manifest.json")
  end

  def service_worker
    render file: Rails.root.join("app/javascript/service_worker.js")
  end
end
