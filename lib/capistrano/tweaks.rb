# encoding: UTF-8
# frozen_string_literal: true

def execute_interactively(command, server)
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
          execute_interactively command([:rails, 'console'], {}).to_command, @host
        end
      end
    end
  end
end

set :rvm_map_bins,   fetch(:rvm_map_bins, []) + %w( rails )
set :rbenv_map_bins, fetch(:rbenv_map_bins, []) + %w( rails )
