# frozen_string_literal: true

# Desktop notification helper for notify-send based system update messages.
module Notification
  DEFAULTS = {
    app: 'System Update', replace_id: nil, icon: nil,
    body: '', actions: {}, timeout: 0, silent: true
  }.freeze

  module_function

  # @param opts [Hash] overrides for DEFAULTS (all keys optional)
  def show(title:, **opts)
    opts = DEFAULTS.merge(opts)
    return if opts[:silent]

    IO.popen(build_command(title, opts), &:read).strip
  end

  def build_command(title, opts)
    cmd = ['notify-send', '-a', opts[:app], '-t', opts[:timeout].to_s]
    cmd += ['-r', opts[:replace_id].to_s] if opts[:replace_id]
    cmd += ['-i', opts[:icon]] if opts[:icon]
    opts[:actions].each { |key, label| cmd << "--action=#{key}=#{label}" }
    cmd += [title, opts[:body]]
  end

  private_class_method :build_command
end
