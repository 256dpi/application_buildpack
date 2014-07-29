action :before_compile do
end

action :before_deploy do
end

action :before_migrate do
  package 'curl'

  %w(source cache env).each do |dir|
    directory "#{new_resource.path}/shared/buildpack_#{dir}" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
  end

  git "#{new_resource.path}/shared/buildpack_source" do
    repository new_resource.buildpack_repository
    revision new_resource.buildpack_revision
    action :sync
  end

  compile_script = "#{new_resource.path}/shared/buildpack_source/bin/compile"
  cache_directory = "#{new_resource.path}/shared/buildpack_cache"
  env_directory = "#{new_resource.path}/shared/buildpack_env"

  execute "#{compile_script} #{new_resource.release_path} #{cache_directory} #{env_directory}" do
    cwd new_resource.release_path
    user new_resource.owner
  end
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end
