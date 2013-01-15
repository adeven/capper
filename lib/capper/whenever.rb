load "capper/ruby"

set(:whenever_command) { "#{ruby_exec_prefix} whenever" }
set(:whenever_identifier) { application }
set(:whenever_environment) { fetch(:rails_env, "production") }
set(:whenever_update_flags) { "--update-crontab #{whenever_identifier} --set environment=#{whenever_environment}" }
set(:whenever_clear_flags) { "--clear-crontab #{whenever_identifier}" }

after "deploy:update_code", "whenever:clear_crontab"
after "deploy:create_symlink", "whenever:update_crontab"
after "deploy:rollback", "whenever:update_crontab"

namespace :whenever do
  desc "Update application's crontab entries"
  task :update_crontab, :roles => :cron, :on_no_matching_servers => :continue do
    on_rollback do
      if previous_release
        run "cd #{previous_release} && #{whenever_command} #{whenever_update_flags}"
      else
        run "crontab /dev/null"
      end
    end

    run "cd #{current_path} && #{whenever_command} #{whenever_update_flags}"
  end

  desc "Remove all entries from application's crontab"
  task :clear_crontab, :roles => :cron, :on_no_matching_servers => :continue do
    run "crontab /dev/null"
  end
end
