# frozen_string_literal: true

require "rails/railtie"

module OpenGraphPlus
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "opengraphplus.helpers" do
        ActiveSupport.on_load(:action_controller) do
          include OpenGraphPlus::Rails::Controller
        end

        ActiveSupport.on_load(:action_view) do
          include OpenGraphPlus::Rails::Helper
        end
      end
    end
  end
end
