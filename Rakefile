desc 'share cookbook'
task :share do
  # `sudo mkdir -p /var/chef/cache/checksums`
  # `sudo chown -R 256dpi: /var/chef`
  `knife cookbook site share application_buildpack Other -o .. -k 256dpi.pem -u 256dpi`
end
