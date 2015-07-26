def config_define_tasks(int = nil, &block)
  int ||= Integration.new
  int.configure(&block)

  int.descriptions.set?(:subject, 'config')

  desc Integration.task_description(:install, int.descriptions)
  task :install do
    on roles(int.roles) do |role|
      install_path  = derive_install_path(int)
      template_path = derive_template_path(int)
      template = config_resolve_template(template_path, role: role)
      config   = config_render_template(template, role: role)
      config_install_remotely(config, install_path)
    end
  end

  desc Integration.task_description(:uninstall, int.descriptions)
  task :uninstall do
    on roles(int.roles) do
      config_uninstall_remotely(derive_install_path(int))
    end
  end

  desc Integration.task_description(:fix_permissions, int.descriptions)
  task :fix_permissions do
    on roles(int.roles) do
      config_fix_permissions(
        derive_install_path(int),
        int.config.permissions.mode,
        int.config.permissions.owner
      )
    end
  end

  desc Integration.task_description(:make_symlinks, int.descriptions)
  task :make_symlinks do
    on roles(int.roles) do
      config_make_symlinks(derive_install_path(int), int.config.symlinks)
    end
  end

  desc Integration.task_description(:remove_symlinks, int.descriptions)
  task :remove_symlinks do
    on roles(int.roles) do
      config_remove_symlinks(int.config.symlinks)
    end
  end

  after :install, :fix_permissions
  after :install, :make_symlinks
  after :uninstall, :remove_symlinks
end

def derive_template_dir(int)
  int.config.template_dir || File.dirname(int.config.template_path)
end

def derive_template_name(int)
  int.config.template_name || File.basename(derive_template_path(int))
end

def derive_template_path(int)
  int.config.template_path || File.join(int.config.templdate_dir, int.config.template_name)
end

def derive_install_dir(int)
  int.config.install_dir || File.dirname(int.config.install_path)
end

def derive_install_name(int)
  int.config.install_name || (int.config.set?(:install_path) && File.basename(int.config.install_path)) ||
    File.basename(derive_template_name(int), '*.erb')
end

def derive_install_path(int)
  int.config.install_path || File.join(int.config.install_dir, derive_install_name(int))
end

def ensure_template_data_provided!(int)
  unless set?(:template_path) || (set?(:template_dir) && set?(:template_name))
    raise 'Template data not provided!'
  end
end

def ensure_install_data_provided!(int)
  unless set?(:install_path) || (set?(:install_dir) && (set?(:template_path) || set?(:template_name)))
    raise 'Install data not provided!'
  end
end

def config_install_remotely(config, config_path)
  config_backup_remotely(config_path)

  config_name     = File.basename(config_path)
  config_tmp_path = "#{fetch(:tmp_dir)}/#{config_name}"
  stream          = StringIO.new(config)

  upload!(stream, config_tmp_path)

  sudo "mkdir -p #{File.dirname(config_path)}"
  sudo "mv #{config_tmp_path} #{config_path}"
end

def config_uninstall_remotely(config_path)
  config_backup_remotely(config_path)
  sudo "rm -f #{config_path}"
end

def config_fix_permissions(config_path, mode, owner = nil)
  sudo "chmod #{mode} #{config_path}" if mode
  sudo "chown #{owner} #{config_path}" if owner
end

def config_make_symlinks(config_path, symlinks)
  Array(symlinks).each do |symlink|
    sudo "ln -fs #{config_path} #{symlink}"
  end
end

def config_remove_symlinks(symlinks)
  Array(symlinks).each do |symlink|
    sudo "rm -f #{symlink}"
  end
end

def config_backup_remotely(config_path)
  config_exists = test("[ -f #{config_path} ]")
  sudo "cp #{config_path} #{config_path}.bak" if config_exists
end

def config_resolve_template(template_path, options = {})
  basename    = File.basename(template_path, '.*')
  dot_ext     = File.extname(template_path).sub(/\A\.+/, '.')

  role        = options[:role]
  hostname    = options[:hostname]
  hostname    = (role.properties.name || role.hostname) if role && hostname.nil?

  stage       = options[:stage]
  stage       = fetch(:stage) if stage.nil?

  tmpl_dirs   = ['config', File.dirname(template_path)]
  tmpl_exts   = ['.erb', '']
  tmpl_names  = %W(
    #{basename}_#{hostname}_#{stage}#{dot_ext}
    #{basename}_#{hostname}#{dot_ext}
    #{basename}_#{stage}#{dot_ext}
    #{basename}#{dot_ext}
  )

  tmpl_dirs.each do |tdir|
    tmpl_names.each do |tname|
      tmpl_exts.each do |text|
        tpath = "#{tdir}/#{tname}#{text}"
        if File.file?(tpath)
          info "Resolved config template '#{tpath}'"
          return File.read(tpath)
        end
      end
    end
  end

  error "Config template '#{template_path}' could not be resolved!"
end

def config_render_template(template, options = {})
  @role = options[:role]
  ERB.new(template).result(binding)
end