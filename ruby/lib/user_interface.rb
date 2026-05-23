# frozen_string_literal: true

require_relative 'notification'
require_relative 'terminal_style'

# Handles notifications and terminal prompts
module UserInterface
  module_function

  # @param options [Hash] SystemUpdater options hash (e.g. :silent_run)
  def prompt_user(needs_reboot, log_file, options)
    reboot_msg = needs_reboot ? "\nA system reboot is required to finish updates." : ''
    t1 = Thread.new { show_final_notification(needs_reboot, reboot_msg, options, log_file) }
    t2 = Thread.new { show_terminal_prompt(reboot_msg, log_file) }
    [t1, t2].each(&:join)
  end

  # @param options [Hash] SystemUpdater options hash (e.g. :silent_run)
  def show_final_notification(needs_reboot, reboot_msg, options, log_file)
    return if options[:silent_run]

    icon = needs_reboot ? 'system-reboot' : 'mintupdate-up-to-date'
    actions = { 'log' => '📂 View Logs', 'reboot' => '🔄 Reboot', 'shutdown' => '💡 Power-off' }
    action = Notification.show(title: 'Update Complete', body: reboot_msg,
                               icon: icon, silent: false, actions: actions)
    handle_notification_action(action, log_file)
  end

  # @param action [String, nil] notify-send action key ('log', 'reboot', 'shutdown') or nil
  def handle_notification_action(action, log_file)
    case action
    when 'log' then exec('xdg-open', File.dirname(log_file))
    when 'reboot'
      puts "#{Style::OK}Rebooting...#{Style::NC}"
      exec('sudo', 'reboot')
    when 'shutdown'
      puts "#{Style::OK}Powering off...#{Style::NC}"
      exec('sudo', 'poweroff')
    end
  end

  def show_terminal_prompt(reboot_msg, log_file)
    puts "#{Style::ERROR}#{reboot_msg}#{Style::NC}\n" unless reboot_msg.empty?
    menu = "#{Style::BRIGHT_RED}󰐥 (p) Poweroff#{Style::NC}  #{Style::BRIGHT_YELLOW} (r) Reboot#{Style::NC}  " \
           "#{Style::INFO}󰝰 (l) Open Log#{Style::NC}  #{Style::FG_DIM}󰿅 [any key] Exit#{Style::NC}"
    puts "\n#{menu}"

    $stdin.reopen('/dev/tty')
    handle_user_choice($stdin.getch, log_file)
  end

  def handle_user_choice(choice, log_file)
    case choice
    when 'r'
      puts "#{Style::OK}Rebooting...#{Style::NC}"
      exec('sudo', 'reboot')
    when 'p'
      puts "#{Style::OK}Powering off...#{Style::NC}"
      exec('sudo', 'poweroff')
    when 'l' then exec('xdg-open', File.dirname(log_file))
    else exit 0
    end
  end

  # @param opts [OptionParser] parser instance, printed as the options summary
  def show_help(opts)
    Style.print_title ' SYSTEM UPDATE: HELP'
    Style.print_header "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS]"
    desc = 'Fedora updator: Handles DNF, security, kernel/driver, flatpak, font cache, and nvidia akmods.'
    puts "#{Style::ACCENT}#{desc}#{Style::NC}"
    Style.print_header 'Options'
    puts opts
    exit
  end
end
