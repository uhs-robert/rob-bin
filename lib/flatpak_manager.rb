# frozen_string_literal: true

require_relative 'shell'
require_relative 'terminal_style'

# Logic for Flatpak package management
class FlatpakManager
  attr_reader :count

  def initialize(updater)
    @updater = updater
    @count = 0
  end

  def update
    return if @updater.options[:skip_flatpak]

    @updater.step('󰏓 Flatpak Updates') do
      pending = Shell.with_spinner('Checking Flatpak updates...') do
        Shell.capture('flatpak', 'remote-ls', '--updates')
      end.lines.length
      pending.positive? ? perform_update(pending) : puts('Nothing to do.')
    end
  end

  def cleanup
    return if @updater.options[:skip_flatpak]

    Style.print_subheader 'Flatpak Packages'
    output = Shell.with_spinner('Checking unused Flatpaks...') do
      Shell.capture('flatpak', 'uninstall', '--unused', '-y')
    end.strip
    if output.downcase.include?('nothing unused')
      puts '  Nothing to do.'
    else
      puts "  #{Style::OK}#{output}#{Style::NC}"
    end
  end

  private

  def perform_update(pending)
    @updater.notify("Updating #{pending} Flatpak packages...")
    output = Shell.with_spinner('Updating Flatpak packages...') do
      Shell.capture('flatpak', 'update', '-y', '--noninteractive')
    end
    puts output.strip unless output.strip.empty?
    @count = pending
    puts "#{Style::OK}Flatpak complete. #{@count} updated.#{Style::NC}"
    @updater.notify("Flatpak update complete. #{@count} packages updated.")
  end
end
