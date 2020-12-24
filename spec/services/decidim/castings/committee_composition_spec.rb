# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Castings
    describe CommitteeComposition do
      let!(:organization) {create(:organization)}
      let!(:casting) {create(:casting, organization: organization, amount_of_candidates: 5)}
      let!(:casting_result) {create(:casting_result, casting: casting)}

      describe "call" do
        it "produces valid result" do
          Decidim::Castings::ImportFileDataSourceJob.perform_now(casting.id)
          Decidim::Castings::CreateCastingDataRowsJob.perform_now(casting.id)
          casting.update(selection_criteria: {
            "town" => {
              "Evere" => 1,
              "Forest" => 1,
              "Etterbeek" => 1,
              "Bruxelles" => 1,
              "Uccle" => 1,
              "Auderghem" => 0,
            },
            "cat_age" => {
              "2" => 1,
              "3" => 2,
              "4" => 1,
              "5" => 1,
            },
            "cat_gender" => {
              "Femme" => 3,
              "Homme" => 2,
            },
            "cat_school_grade" => {
              "2" => 2,
              "3" => 2,
              "4" => 1,
            }
          })

          described_class.new(casting_result).call
          casting.casting_data_rows.delete_all

          expect(casting_result.statistics).not_to be_blank
          expect(casting_result.statistics['total_candidates']).to eq(5)
          casting.reload.selection_criteria.each do |attr, values|
            values.each do |k, v|
              expect(casting_result.statistics.dig('candidates_attributes', attr, k)).to eq(v == 0 ? nil : v)
            end
          end

          %w(Evere Forest Etterbeek Bruxelles Uccle).each do |town|
            expect(casting_result.candidates_file.read).to include(town)
          end
          %w(Auderghem).each do |town|
            expect(casting_result.candidates_file.read).not_to include(town)
          end

        end

      end
    end
  end
end
