def daemon_define_tasks(integration = nil, &block)
  integration ||= Integration.new
  integration.configure(&block)
  integration.descriptions.set?(:scope, "[#{integration.service} daemon]")
  integration.descriptions.set?(:subject, "#{integration.service} daemon")

  [:start, :stop, :restart, :status, :reload].each do |cmd|
    desc Integration.task_description(cmd, integration.descriptions)
    task cmd do
      on roles(integration.roles) do
        sudo :service, "#{integration.service} #{cmd}"
      end
    end
  end
end