def production_as_default_stage!
  if ARGV[0] && File.file?(File.join(stage_config_path, "#{ARGV[0]}.rb"))
    invoke(ARGV[0])
  else
    invoke(:production)
  end
end

def result_of(value, *args)
  value = self.option(option)
  value.respond_to?(:call) ? value.call(*args[0...value.arity]) : value
end

def run_interactively(command, server)
  exec %Q(ssh #{server.user}@#{server.hostname} -t '#{command}')
end

def within_user(user, command)
  "su #{user || fetch(:user)} #{command}"
end

def within_zsh_shell(command, options = {})
  "#{'sudo ' if options[:sudo]}#{within_user(options[:user], "zsh -l -c '#{command}'")}"
end

def expand_home_dir(command, options = {})
  command.gsub(/\A~/, "/home/#{options[:user]}")
end