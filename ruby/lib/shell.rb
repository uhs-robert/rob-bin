# frozen_string_literal: true

require 'open3'
require 'pty'
require 'io/console'
require_relative 'terminal_style'

# Provides shell-related helper methods including process execution and output capture.
module Shell
  module_function

  def pty_run(*)
    rows, cols = IO.console&.winsize || [24, 80]
    PTY.spawn(*) do |reader, _writer, pid|
      setup_reader(reader, rows, cols)
      copy_stream(reader)
      Process.wait(pid)
    end
  end

  def setup_reader(reader, rows, cols)
    reader.winsize = [rows, cols]
  rescue Errno::ENOTTY
    # Ignore if terminal doesn't support winsize
  end

  def copy_stream(reader)
    loop { print reader.readpartial(4096) }
  rescue Errno::EIO, EOFError
    # End of stream
  end

  def capture(*)
    stdout, _stderr, _status = Open3.capture3(*)
    stdout
  end

  SPINNER_FRAMES = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏].freeze

  def with_spinner(label = '')
    return yield unless $stdout.tty?

    $stdout.print("\e[?25l")
    spinner = Thread.new { spin_loop(label) }
    yield
  ensure
    spinner&.kill
    spinner&.join
    $stdout.print("\r\e[2K")
    $stdout.print("\e[?25h")
  end

  def spin_loop(label)
    SPINNER_FRAMES.cycle.each do |frame|
      $stdout.print("\r#{Style::ACCENT}#{frame}#{Style::NC} #{Style::FG_DIM}#{label}#{Style::NC}")
      $stdout.flush
      sleep(0.08)
    end
  end
end
