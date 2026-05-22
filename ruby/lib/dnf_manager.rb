# frozen_string_literal: true

require_relative 'shell'
require_relative 'terminal_style'

# Logic for DNF package management
class DnfManager
  attr_reader :count, :needs_reboot

  def initialize(updater)
    @updater = updater
    @count = 0
    @needs_reboot = false
  end

  def refresh_cache
    return if @updater.options[:skip_clean_cache]

    @updater.step('󰃨 Refreshing DNF Cache', 'Refreshing DNF cache...', icon: 'mintupdate-checking', log: false) do
      Shell.pty_run('sudo', 'dnf', 'makecache', '--refresh', *@updater.dnf_flags)
    end
    @updater.log_message('Cache updated.')
  end

  def update
    @updater.step(' DNF Updates', 'Checking for DNF updates...') do
      output = Shell.with_spinner('Checking DNF updates...') { Shell.capture('dnf', 'check-update') }
      parse_output(output)
      @count.positive? ? perform_update : notify_none
    end
  end

  def security
    return if @updater.options[:skip_security]

    @updater.step('󰒃 Security Updates', 'Checking for security updates...') do
      apply_security_updates
    end
  end

  def apply_security_updates
    output = Shell.with_spinner('Checking security updates...') do
      Shell.capture('sudo', 'dnf', 'check-update', '--security')
    end
    if output.include?('Security')
      Shell.pty_run('sudo', 'dnf', 'update', '--security', *@updater.dnf_flags)
      puts "#{Style::OK}Installed security updates.#{Style::NC}"
    else
      puts 'Nothing to do.'
    end
  end

  def autoremove
    Style.print_subheader 'DNF Packages'
    output = Shell.with_spinner('Running autoremove...') do
      Shell.capture('sudo', 'dnf', 'autoremove', *@updater.dnf_flags)
    end.strip
    color = output.downcase.include?('nothing to do') ? '' : Style::ACCENT
    puts "  #{color}#{output}#{Style::NC}"
  end

  def post_process
    return unless @count.positive?

    if @font_updates.positive?
      @updater.step('󰃨 Rebuilding Font Cache', 'Rebuilding font cache...') do
        system('fc-cache', '-fv')
      end
    end
    perform_kernel_maintenance if @nvidia_updates.positive? || @kernel_updates.positive?
  end

  private

  def parse_output(output)
    @count = output.scan(/ updates$/).length
    @nvidia_updates = output.downcase.scan('nvidia').length
    @kernel_updates = output.downcase.scan('kernel').length
    @font_updates = output.downcase.scan('font').length
  end

  def perform_update
    @updater.notify("DNF updating #{@count} packages...")
    Shell.pty_run('sudo', 'dnf', 'update', *@updater.dnf_flags)
    @updater.notify("DNF update complete. #{@count} packages updated.")
  end

  def notify_none
    @updater.notify('No DNF updates found.')
    puts 'Nothing to do.'
  end

  def perform_kernel_maintenance
    @updater.step(' Performing Driver/Kernel Maintenance', 'Maintenance detected...') do
      new_kernel = query_new_kernel
      rebuild_kernel_modules(new_kernel)
      @needs_reboot = true
    end
  end

  def query_new_kernel
    Shell.with_spinner('Querying kernel version...') do
      # rubocop:disable Style/FormatStringToken -- rpm queryformat syntax, not Ruby format string
      Shell.capture('rpm', '-q', '--qf', '%{VERSION}-%{RELEASE}.%{ARCH}\n', 'kernel-core')
      # rubocop:enable Style/FormatStringToken
    end.lines.map(&:strip).max
  end

  # @param new_kernel [String] kernel version string, e.g. "6.14.4-301.fc42.x86_64"
  def rebuild_kernel_modules(new_kernel)
    puts "#{Style::SECONDARY}Refreshing akmods for: #{new_kernel}#{Style::NC}"
    system('sudo', 'akmods', '--force', '--kernel', new_kernel)
    puts "#{Style::SECONDARY}Running dracut for: #{new_kernel}#{Style::NC}"
    system('sudo', 'dracut', '--force', '--add', 'bluetooth', "/boot/initramfs-#{new_kernel}.img", new_kernel)
  end
end
