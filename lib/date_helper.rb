module ActionView
  module Helpers
    module DateHelper
      def short_time_ago_in_words(from_time)
        to_time = Time.now
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
        when 0..1
          "#{distance_in_seconds}s"
        when 2..44           then "#{distance_in_minutes}m"
        when 45..1439        then "#{(distance_in_minutes.to_f / 60.0).round}hr"
        when 1440..43199     then "#{(distance_in_minutes.to_f / 1440.0).round}d"
        when 43200..525599   then "#{(distance_in_minutes.to_f / 43200.0).round}mo"
        else
          "#{distance_in_minutes / 525600}y"
        end
      end
    end
  end
end
