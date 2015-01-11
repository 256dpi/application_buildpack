include Chef::DSL::IncludeRecipe

action :before_compile do
  include_recipe 'monit'
  ensure_restart_command
end

action :before_deploy do
  helper = ApplicationHelper.new(new_resource.application.path, new_resource.name, node)
  update_monit_files(helper) if helper.procfile?
end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do
  helper = ApplicationHelper.new(new_resource.application.path, new_resource.name, node)
  ensure_directories(helper)
  update_monit_files(helper)
end

action :after_restart do
end

protected

def ensure_restart_command
  unless new_resource.restart_command
    new_resource.restart_command do
      execute 'application_buildpack_reload' do
        command "touch /var/local/#{new_resource.name}/*.reload"
      end
    end
  end
end

def ensure_directories(helper)
  directory helper.lock_path do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  directory helper.pid_path do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  directory helper.log_path do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

def update_monit_files(helper)
  new_resource.processes.each do |type, options|
    if options[1] && options[1].key?(:run)
      create_monit_files(helper, type, options, options[1][:run])
    elsif helper.procfile_processes.include?(type)
      create_monit_files(helper, type, options)
    else
      Chef::Log.warn("missing procfile entry for '#{type}'")
    end
  end
end

def create_monit_files(helper, type, options, process_override = nil)
  create_lock_directory(helper)
  create_lock_file(helper, type, 'restart')
  create_lock_file(helper, type, 'reload')
  create_environment_sh(helper)
  create_initscript(helper, type, process_override || helper.process(type))
  create_monitrc(helper, type, options[0], options[1])
end

def create_lock_file(helper, type, suffix)
  file ::File.join(helper.lock_path, "#{type}.#{suffix}") do
    owner 'root'
    group 'root'
    mode '0644'
    action :create_if_missing
  end
end

def create_lock_directory(helper)
  directory helper.lock_path do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

def create_environment_sh(helper)
  execute 'application_buildpack_reload' do
    command "touch #{::File.join(helper.lock_path, '*.reload')}"
    action :nothing
  end

  template helper.environment_sh_path do
    source 'scale/environment.sh.erb'
    cookbook 'application_buildpack'
    owner 'root'
    group 'root'
    mode '0755'
    variables ({
      path_prefix: new_resource.application.environment['PATH_PREFIX'],
      environment_attributes: new_resource.application.environment
    })
    notifies :run, 'execute[application_buildpack_reload]', :delayed
  end
end

def create_initscript(helper, type, command)
  template helper.init_path(type) do
    cookbook 'application_buildpack'
    source 'scale/procfile.init.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables ({
      name: new_resource.name,
      type: type,
      command: command,
      environment_sh_path: helper.environment_sh_path,
      pid_path: helper.pid_path,
      log_path: helper.log_path,
      current_path: helper.current_path
    })
  end
end

def create_monitrc(helper, type, number, options)
  execute 'application_buildpack_monit_reload' do
    command 'monit reload'
    action :nothing
  end

  template helper.monitrc_path(type) do
    cookbook 'application_buildpack'
    source 'scale/procfile.monitrc.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables ({
      name: new_resource.name,
      type: type,
      number: number,
      options: options,
      pid_prefix: ::File.join(helper.pid_path, type),
      lock_path: helper.lock_path
    })
    notifies :run, 'execute[application_buildpack_monit_reload]', :immediately
  end
end
