# frozen_string_literal: true

module Decidim
  class CastingDataRow < ApplicationRecord

    belongs_to :casting,
               foreign_key: "decidim_casting_id",
               class_name: "Decidim::Casting"

  end
end
