# frozen_string_literal: true

# Writes to two IO streams simultaneously, delegating tty? to the primary.
# The secondary (log file) receives clean plain text: ANSI codes stripped,
# carriage-return overwrites resolved to their final value.
class TeeIO
  ANSI_RE = /\e(?:\[[0-9;?]*[a-zA-Z]|\][^\a]*(?:\a|\e\\))/

  def initialize(primary, secondary)
    @primary   = primary
    @secondary = secondary
    @line_buf  = +''
    @logging   = true
  end

  attr_writer :logging

  def write(*args) = @primary.write(*args).tap { log(args.join) }
  def puts(*args)  = @primary.puts(*args).tap  { (args.empty? ? [''] : args).each { |a| log("#{a}\n") } }
  def print(*args) = @primary.print(*args).tap { log(args.join) }
  def flush        = @primary.flush.tap        { @secondary.flush }
  def tty?         = @primary.tty?

  def sync=(val)
    @primary.sync = val
  end

  def log_only(msg)
    @secondary.write("#{msg}\n")
  end

  private

  def log(raw)
    return unless @logging

    clean = raw.gsub(ANSI_RE, '').gsub("\r\n", "\n")
    clean.scan(/[^\r\n]*[\r\n]|[^\r\n]+\z/).each { |chunk| log_chunk(chunk) }
  end

  def log_chunk(chunk)
    if chunk.end_with?("\n")
      @secondary.write("#{@line_buf}#{chunk.chomp}\n")
      @line_buf = +''
    elsif chunk.end_with?("\r")
      @line_buf = +''
    else
      @line_buf << chunk
    end
  end
end
