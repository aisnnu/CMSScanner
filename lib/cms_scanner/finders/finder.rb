require 'cms_scanner/finders/finder/smart_url_checker'
require 'cms_scanner/finders/finder/enumerator'
require 'cms_scanner/finders/finder/fingerprinter'
require 'cms_scanner/finders/finder/breadth_first_dictionary_attack'

module CMSScanner
  module Finders
    # Finder
    class Finder
      # Constants for common found_by
      DIRECT_ACCESS = 'Direct Access (Aggressive Detection)'.freeze

      attr_accessor :target, :progress_bar

      def initialize(target)
        @target = target
      end

      # @return [ String ] The titleized name of the finder
      def titleize
        self.class.to_s.demodulize.underscore.titleize
      end

      # @param [ Hash ] _opts
      def passive(_opts = {}); end

      # @param [ Hash ] _opts
      def aggressive(_opts = {}); end

      # @param [ Hash ] opts See https://github.com/jfelchner/ruby-progressbar/wiki/Options
      # @option opts [ Boolean ] :show_progression
      #
      # @return [ ProgressBar::Base ]
      def create_progress_bar(opts = {})
        bar_opts          = { format: '%t %a <%B> (%c / %C) %P%% %e' }
        bar_opts[:output] = ProgressBarNullOutput unless opts[:show_progression]

        @progress_bar = ::ProgressBar.create(bar_opts.merge(opts))
      end

      # @return [ Browser ]
      def browser
        @browser ||= NS::Browser.instance
      end

      # @return [ Typhoeus::Hydra ]
      def hydra
        @hydra ||= browser.hydra
      end

      # @param [ String, Symbol ] klass
      # @return [ String ]
      def found_by(klass = self)
        caller_locations.each do |call|
          label = call.label

          next unless %w[aggressive passive].include? label

          return "#{klass.titleize} (#{label.capitalize} Detection)"
        end
        nil
      end
    end
  end
end
