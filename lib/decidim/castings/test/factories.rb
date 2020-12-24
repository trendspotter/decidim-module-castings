# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :casting, class: "Decidim::Casting" do
    organization
    author {create(:user, :confirmed, organization: organization)}
    title {Faker::Name.name}
    amount_of_candidates {40}
    selection_criteria {{}}
    file {Rack::Test::UploadedFile.new(File.expand_path(File.join("spec/assets", "casting_file_example_1.csv")), 'text/csv')}
    # file {File.open(File.join("spec/assets", "good.csv"))}
    file_content_type {'text/csv'}
    file_size {0}
  end

  factory :casting_result, class: "Decidim::CastingResult" do
    casting
    run_number {0}
    number_of_trials {0}
  end
end
