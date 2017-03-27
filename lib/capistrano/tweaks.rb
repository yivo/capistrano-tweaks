# encoding: UTF-8
# frozen_string_literal: true

def production_as_default_stage!
  if ARGV[0] && File.file?(File.join(File.expand_path(stage_config_path, Rake.application.original_dir), "#{ARGV[0]}.rb"))
    invoke(ARGV[0])
  else
    invoke(:production)
  end
end

def run_interactively(command, server)
  exec "ssh", "#{server.user}@#{server.hostname}", "-t", command
end

# expand_home_dir('~/dir', user: 'deploy') => /home/deploy/dir
def expand_home_dir(command, options = {})
  "/home/#{options.fetch(:user)}#{command[1..-1]}"
end

namespace :rails do
  desc 'Remote application console'
  task console: ['deploy:set_rails_env'] do
    on release_roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          run_interactively command([:rails, 'console'], {}).to_command, @host
        end
      end
    end
  end
end

set :rvm_map_bins,   fetch(:rvm_map_bins, []) + %w( rails )
set :rbenv_map_bins, fetch(:rbenv_map_bins, []) + %w( rails )
