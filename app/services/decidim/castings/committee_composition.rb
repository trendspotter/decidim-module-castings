# frozen_string_literal: true

module Decidim
  module Castings
    class CommitteeComposition
      attr_accessor :result, :candidates, :substitutes

      def initialize(casting_result)
        @result = casting_result
        #
        # @result = Decidim::CastingResult.find(7)
        #
        init
      end

      def init
        @casting = @result.casting
        @data_rows = @casting.casting_data_rows
        @attrs = @casting.selection_criteria.keys
        @candidates = []
        @substitutes = []
      end

      def call
        init
        @result.update_column(:number_of_trials, 0)

        find_candidates
        find_substitutes
        save_stats
      end

      private

      def find_candidates
        @criteria = @casting.selection_criteria.deep_dup

        for i in 1..@casting.amount_of_candidates do
          _get_constraints.each do |cc|
            @result.update_column(:number_of_trials, @result.number_of_trials + 1)

            pool = @data_rows.where.not(id: @candidates.map(&:id))

            @criteria.each do |attr, values|
              values.each do |k, v|
                pool = pool.where.not("attrs @> '#{{attr => k}.to_json}'") if v == 0
              end
            end

            person = pool.where("attrs @> '#{{cc[:attr] => cc[:value]}.to_json}'").order('RANDOM()').first
            if person.present?
              @candidates << person
              person.attrs.each do |k, v|
                if @criteria.dig(k, v).present?
                  @criteria[k][v] -= 1
                end
              end

              break # Person found, break `_get_constraints.each` to find next candidate
            else
              # Person not found, try next constraint
            end
          end
        end
      end

      def _get_constraints
        constraints = []
        @attrs.each do |attr|
          if @criteria[attr].values.any? {|v| v > 0}
            data_counts = _data_attr_counts(attr)
            constraints << @criteria[attr].map {|k, v| {attr: attr, value: k, coeff: v.to_f / data_counts[k]}}.max {|r| r[:coeff]}
          end
        end
        constraints.sort! {|a, b| b[:coeff] <=> a[:coeff]}
      end

      def _data_attr_counts(attr)
        q = %Q{
          SELECT v AS value, count(v) AS count
          FROM
            (SELECT jsonb_extract_path_text(attrs, '#{attr}') v
             FROM
               decidim_casting_data_rows
             WHERE
               decidim_casting_id = #{@casting.id}
            ) as tt
          GROUP BY v
          ORDER BY count asc
        }
        result = []
        ActiveRecord::Base.logger.silence do
          result = ActiveRecord::Base.connection.execute(q)
        end
        result.map {|r| [r['value'], r['count']]}.to_h
      end

      def find_substitutes
        return [] if @candidates.blank?

        @candidates.each do |candidate|
          pool = @data_rows.where.not(id: @candidates.map(&:id))

          @casting.selection_criteria.keys.each do |attr|
            pool = pool.where("attrs @> '#{{attr => candidate.attrs['age']}.to_json}'")
          end
          person = pool.order('RANDOM()').first

          if person.present?
            person.attrs['__substitute_for'] = candidate.id
            @substitutes << person
          end
        end
      end

      def save_stats
        c_stats = _fill_stats(@candidates)
        s_stats = _fill_stats(@substitutes)

        stats = {
          total_candidates: @candidates.count,
          total_substitutes: @substitutes.count,
          candidates_attributes: c_stats,
          substitutes_attributes: s_stats
        }

        @result.update_column(:statistics, stats)
      end

      def _fill_stats(persons)
        _stats = {}
        @attrs.each {|h| _stats[h] = {}}

        persons.each do |p|
          @attrs.each do |attr|
            value = p.attrs[attr]
            _stats[attr][value] = 0 if _stats[attr][value].blank?
            _stats[attr][value] += 1
          end
        end

        _stats
      end
    end
  end
end
