class Integration < Confo::Config
  includes_config :descriptions, class_name: 'Integration::Descriptions'
  includes_config :config, class_name: 'Integration::Config'

  option_accessor :roles

  class Descriptions < Confo::Config
    def task(task, *args)
      texts = @texts ||= {}
      if args.size > 0
        texts[task.to_sym] = args.first
        self
      else
        Confo.result_of(texts[task.to_sym])
      end
    end
  end

  class Config < Confo::Config
    includes_config :permissions, class_name: 'Integration::Permissions'

    # option :install_path
    # option :install_name
    # option :install_dir
    #
    # option :template_path
    # option :template_name
    # option :template_dir
    #
    # def template_dir
    #   ensure_template_data_provided!
    #   super || File.dirname(template_path)
    # end
    #
    # def template_path
    #   ensure_template_data_provided!
    #   super || File.join(template_dir, template_name)
    # end
    #
    # def install_dir
    #   ensure_install_data_provided!
    #   super || File.dirname(install_path)
    # end
    #
    # def install_name
    #   ensure_install_data_provided!
    #   super || (set?(:install_path) && File.basename(install_path)) ||
    #     File.basename(template_name, '*.erb')
    # end
    #
    # def install_path
    #   ensure_install_data_provided!
    #   super || File.join(install_dir, install_name)
    # end
    #
    # private
    #
    # def ensure_template_data_provided!
    #   unless set?(:template_path) || (set?(:template_dir) && set?(:template_name))
    #     raise 'Template data not provided!'
    #   end
    # end
    #
    # def ensure_install_data_provided!
    #   unless set?(:install_path) || (set?(:install_dir) && (set?(:template_path) || set?(:template_name)))
    #     raise 'Install data not provided!'
    #   end
    # end

  end

  class Permissions < Confo::Config
    option_accessor :owner
    option_accessor :mode
  end

  class << self
    def task_description(task, descriptions)
      desc = descriptions.task(task)

      desc ||= if text = (descriptions.text || descriptions.default_text)
        Confo.result_of(text, task)
      else
        pieces  = task.to_s.split('_')
        subject = descriptions.subject
        "#{pieces.first.to_s.capitalize}#{" #{subject}" if subject} #{pieces.drop(1).join(' ')}"
      end || ''

      if (scope = descriptions.scope) && scope.length > 0
        desc = "#{scope} #{desc}"
      end
      desc.strip
    end

    def filter_tasks(tasks, filter)
      except    = Array(filter.except)
      only      = Array(filter.only)
      supports  = Array(filter.supports)

      tasks.select do |t|
        (!filter.except || !except.include?(t)) &&
          (!filter.only || only.include?(t)) &&
          (!filter.supports || supports.include?(t))
      end
    end
  end
end