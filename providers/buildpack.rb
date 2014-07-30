include Chef::DSL::IncludeRecipe

REPOSITORIES = {
  ruby: 'https://github.com/heroku/heroku-buildpack-ruby.git',
  nodejs: 'https://github.com/heroku/heroku-buildpack-nodejs.git'
}

action :before_compile do
end

action :before_deploy do
  install_base_dependencies
  detect_buildpack
end

action :before_migrate do
  install_buildpack_dependencies
  prepare_directories
  sync_buildpack
  compile_buildpack
  write_wrapper
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end

protected

def install_base_dependencies
  %w(git curl).each do |pkg|
    package pkg
  end
end

def detect_buildpack
  unless %w(ruby nodejs).include?(new_resource.language.to_s)
    raise "buildpack language not detected: #{new_resource.language}"
  end

  if new_resource.buildpack_repository.nil?
    if REPOSITORIES.include?(new_resource.language)
      new_resource.buildpack_repository REPOSITORIES[new_resource.language]
    end
  end
end

def install_buildpack_dependencies
  self.send(:"install_#{new_resource.language}_dependencies")
end

def install_nodejs_dependencies
end

def install_ruby_dependencies
  %w(autoconf bind9-host bison build-essential daemontools dnsutils iputils-tracepath libcurl4-openssl-dev
    libevent-dev libglib2.0-dev libmcrypt-dev libssl-dev libssl0.9.8 libxml2-dev libxslt-dev netcat-openbsd
    openssh-client openssh-server socat telnet zlib1g zlib1g-dev libyaml-dev libreadline6 libreadline6-dev).each do |pkg|
    package pkg
  end

  include_recipe 'ruby_build'

  ruby_build_ruby '2.1.2' do
    prefix_path '/var/application_buildpack/ruby'
  end

  directory '/var/application_buildpack/ruby/gems'

  new_resource.buildpack_environment.merge! 'PATH' => "/var/application_buildpack/ruby/bin:#{ENV['PATH']}",
                                            'GEM_HOME' => '/var/application_buildpack/ruby/gems'
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

  execute "#{compile_script} #{new_resource.release_path} #{cache_directory}" do
    cwd new_resource.release_path
    user new_resource.owner
    group new_resource.group
    environment new_resource.buildpack_environment
  end
end

def write_wrapper
  template "#{new_resource.release_path}/buildpack_exec" do
    source 'exec.sh.erb'
    cookbook 'application_buildpack'
    owner new_resource.owner
    group new_resource.group
    mode '0755'
    variables root: new_resource.release_path
  end
end
