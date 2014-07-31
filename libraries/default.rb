class ApplicationHelper
  attr_accessor :path
  attr_accessor :name
  attr_accessor :node

  def initialize(path, name, node)
    @path = path
    @name = name
    @node = node
  end

  def current_path
    @current_path ||= ::File.join(@path, 'current')
  end

  def current_release
    @current_release ||= ::File.basename(::File.realpath(self.current_path))[0,7]
  end

  def shared_path
    @shared_path ||= ::File.join(@path, 'shared')
  end

  def init_path(type)
    ::File.join('/etc', 'init.d', "#{name}-#{type}")
  end

  def monitrc_path(type)
    ::File.join('/etc', 'monit', 'conf.d', "#{name}-#{type}.conf")
  end

  def environment_sh_path
    @environment_sh_path ||= ::File.join(self.shared_path, 'environment.sh')
  end

  def procfile_path
    @procfile_path ||= ::File.join(self.current_path, 'Procfile')
  end

  def procfile?
    ::File.exists?(self.procfile_path)
  end

  def procfile
    @procfile ||= YAML.load_file(self.procfile_path)
  end

  def procfile_processes
    self.procfile.keys
  end

  def process(type)
    self.procfile[type.to_s]
  end

  def lock_path
    @lock_path ||= ::File.join('/var', 'local', @name)
  end

  def pid_path
    @pid_path ||= ::File.join('/var', 'local', @name)
  end

  def log_path
    @log_path ||= ::File.join('/var', 'log', @name)
  end
end
