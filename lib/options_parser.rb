# frozen_string_literal: true

require 'optparse'

# Mixin for SystemUpdater: option parsing extracted to keep SystemUpdater within line limits.
module OptionsParser
  def parse_options
    opts_hash = { auto_confirm: true, silent_run: true, skip_security: false,
                  skip_flatpak: false, skip_clean_cache: false }
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS]"
      define_options(opts, opts_hash)
    end
    parser.parse!
    opts_hash
  end

  # @param opts [OptionParser] parser to register flags on
  # @param opts_hash [Hash] mutable result hash populated by flag callbacks
  def define_options(opts, opts_hash)
    opts.on('-n', '--enable-notifications') { opts_hash[:silent_run] = false }
    opts.on('-s', '--skip-security')        { opts_hash[:skip_security] = true }
    opts.on('-f', '--skip-flatpak')         { opts_hash[:skip_flatpak] = true }
    opts.on('-c', '--skip-clean-cache')     { opts_hash[:skip_clean_cache] = true }
    opts.on('-i', '--interactive')          { opts_hash[:auto_confirm] = false }
    opts.on('-h', '--help')                 { show_help(opts) }
  end
end
