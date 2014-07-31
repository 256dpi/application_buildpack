include Chef::Mixin::ShellOut

REPOSITORIES = {
  ruby: 'https://github.com/heroku/heroku-buildpack-ruby.git',
  nodejs: 'https://github.com/heroku/heroku-buildpack-nodejs.git'
}

DEPENDENCIES = {
  base: %w(git curl),
  ruby: %w(autoconf bind9-host bison build-essential daemontools dnsutils iputils-tracepath libcurl4-openssl-dev
    libevent-dev libglib2.0-dev libmcrypt-dev libssl-dev libssl0.9.8 libxml2-dev libxslt-dev netcat-openbsd
    openssh-client openssh-server socat telnet zlib1g zlib1g-dev libyaml-dev libreadline6 libreadline6-dev
    libpq-dev libpq5 libmysqlclient-dev),
  nodejs: %w()
}

DEFAULT_ENV = {
  'STACK' => 'chef'
}

action :before_compile do
  detect_buildpack
end

action :before_deploy do
  install_dependencies(:base)
end

action :before_migrate do
  install_dependencies
  prepare_directories
  sync_buildpack
  compile_buildpack
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end

protected

def install_dependencies(which = nil)
  which ||= new_resource.language
  DEPENDENCIES[which].each{|pkg| package pkg } if DEPENDENCIES.key?(which)
end

def detect_buildpack
  if new_resource.buildpack_repository.nil? && new_resource.language
    if REPOSITORIES.include?(new_resource.language)
      new_resource.buildpack_repository REPOSITORIES[new_resource.language]
    end
  end
end

def prepare_directories
  %w(source cache).each do |dir|
    directory "#{new_resource.path}/shared/buildpack_#{dir}" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
  end
end

def sync_buildpack
  git "#{new_resource.path}/shared/buildpack_source" do
    repository new_resource.buildpack_repository
    revision new_resource.buildpack_revision
    action :sync
  end
end

def compile_buildpack
  compile_script = "#{new_resource.path}/shared/buildpack_source/bin/compile"
  cache_directory = "#{new_resource.path}/shared/buildpack_cache"
  command = "#{compile_script} #{new_resource.release_path} #{cache_directory}"

  ruby_block 'compile buildpack' do
    block do
      Chef::Log.info('start buildpack compilation')
      Chef::Log.info("run: #{command}")

      cmd = Mixlib::ShellOut.new(command, {
        timeout: 3600,
        log_level: :info,
        cwd: new_resource.release_path,
        user: new_resource.owner,
        group: new_resource.group,
        environment: DEFAULT_ENV.merge(new_resource.buildpack_environment)
      })

      cmd.live_stream = STDOUT
      cmd.run_command
      cmd.error!

      Chef::Log.info('compiled successfully')
    end
  end
end
