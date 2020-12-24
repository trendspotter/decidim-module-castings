# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Castings
    describe Casting do
      subject {casting}

      let(:organization) {build(:organization)}
      let(:casting) {build(:casting, organization: organization)}

      it "has an association for organisation" do
        expect(subject.organization).to eq(organization)
      end

      describe "validations" do
        it "is valid" do
          expect(subject).to be_valid
        end

        it "is not valid without an organisation" do
          subject.organization = nil
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
