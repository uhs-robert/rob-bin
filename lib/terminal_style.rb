#!/usr/bin/env ruby
# ruby/terminal_style.rb
# frozen_string_literal: true

require 'json'

# Provides terminal styling utilities including colors and headers.
module Style
  THEME_FILE = File.expand_path('../../themes/Oasis Moonlight Dark.json', __dir__)

  def self.fg(hex)
    r, g, b = hex.delete('#').scan(/../).map { |c| c.to_i(16) }
    "\e[38;2;#{r};#{g};#{b}m"
  end

  def self.bg(hex)
    r, g, b = hex.delete('#').scan(/../).map { |c| c.to_i(16) }
    "\e[48;2;#{r};#{g};#{b}m"
  end

  C = JSON.parse(File.read(THEME_FILE))

  NC           = "\e[0m"
  BOLD         = "\e[1m"
  DIM          = "\e[2m"
  ITALIC       = "\e[3m"
  UNDERLINE    = "\e[4m"

  PRIMARY      = fg(C['theme_primary'])
  SECONDARY    = fg(C['theme_secondary'])
  ACCENT       = fg(C['theme_accent'])

  RED          = fg(C['red'])
  GREEN        = fg(C['green'])
  YELLOW       = fg(C['yellow'])
  BLUE         = fg(C['blue'])
  MAGENTA      = fg(C['magenta'])
  CYAN         = fg(C['cyan'])
  WHITE        = fg(C['white'])

  BRIGHT_RED     = fg(C['bright_red'])
  BRIGHT_GREEN   = fg(C['bright_green'])
  BRIGHT_YELLOW  = fg(C['bright_yellow'])
  BRIGHT_BLUE    = fg(C['bright_blue'])
  BRIGHT_MAGENTA = fg(C['bright_magenta'])
  BRIGHT_CYAN    = fg(C['bright_cyan'])
  BRIGHT_WHITE   = fg(C['bright_white'])

  ERROR   = fg(C['error'])
  WARNING = fg(C['warning'])
  INFO    = fg(C['info'])
  OK      = fg(C['ok'])
  HINT    = fg(C['hint'])

  FG      = fg(C['fg_core'])
  FG_DIM  = fg(C['fg_dim'])
  FG_MUTED = fg(C['fg_muted'])

  @first_title = true

  module_function

  def terminal_width
    require 'io/console'
    IO.console&.winsize&.at(1) || 80
  rescue LoadError, StandardError
    80
  end

  def print_title(title, color: INFO)
    # Support passing color names as symbols or strings (e.g., :primary or "primary")
    color = const_get(color.to_s.upcase) if color.is_a?(Symbol) || (color.is_a?(String) && !color.start_with?("\e["))

    width = terminal_width
    upper = title.upcase
    pad_total = [width - upper.length - 2, 0].max
    pad_left = pad_total / 2
    pad_right = pad_total - pad_left

    prefix = Style.instance_variable_get(:@first_title) ? '' : "\n"
    Style.instance_variable_set(:@first_title, false)
    puts "#{prefix}#{color}#{BOLD}#{'─' * pad_left} #{upper} #{'─' * pad_right}#{NC}"
  end

  def print_header(text)
    puts "\n#{PRIMARY}#{text}#{NC}"
    puts "#{PRIMARY}#{'─' * text.length}#{NC}"
  end

  def print_subheader(text)
    puts "\n #{SECONDARY}#{text}#{NC}"
    puts " #{SECONDARY}#{'─' * text.length}#{NC}"
  end
end
