require "daemons"

# The APN daemon:
#   rake apn[start] - Start the daemon.
#   rake apn[stop] - Stop the daemon.
#   rake apn[restart] - Restart the daemon.
#   rake apn[run] - Run the daemon in the foreground.
#
task :apn, [ :command ] do |task, args|
  # daemon options
  options = {
    :ARGV => [ args[:command] ], 
    :multiple => false,
    :backtrace => true,
    :log_dir => Rails.root.join("log"),
    :log_output => true
  }

  # run daemon
  Daemons.run_proc("apn_daemon", options) do
    Rails.application.require_environment!
    Rails.logger.info "APN Daemon started..."
    loop do
      APN::Notification.send_notifications
      sleep 5
    end
  end
end

