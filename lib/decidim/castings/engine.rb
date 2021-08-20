# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Castings
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Castings

      initializer "decidim_castings extends" do
        Dir.glob("#{Decidim::Castings::Engine.root}/lib/extends/castings/**/*.rb").each do |override|
          require_dependency override
        end
      end

    end
  end
end
