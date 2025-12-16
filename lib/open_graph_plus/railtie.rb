# frozen_string_literal: true

require "rails/railtie"

module OpenGraphPlus
  class Railtie < Rails::Railtie
    initializer "opengraphplus.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include OpenGraphPlus::Controller
      end

      ActiveSupport.on_load(:action_view) do
        include OpenGraphPlus::Helper
      end
    end
  end
end
