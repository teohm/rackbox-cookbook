#
# Cookbook Name:: rackbox
# Recipe:: unicorn
#
# Setup unicorn apps
#

Array(node["rackbox"]["apps"]["unicorn"]).each_with_index do |app, index|

  upstream_port = node["rackbox"]["local_start_port"]["unicorn"] + index
  upstream_server = "localhost:#{upstream_port}"
  app_dir = ::File.join(node["appbox"]["apps_dir"], app["appname"], 'current')

  # Setup nginx virtual host
  app["vhost_config"] ||= {}
  template File.join(node["nginx"]["dir"], "sites-available", app["appname"]) do
    source   app["vhost_config"]["template"]          || "nginx_vhost.conf.erb"
    cookbook app["vhost_config"]["template_cookbook"] || "rackbox"
    mode  "0644"
    owner "root"
    group "root"
    variables({
      :root_path   => ::File.join(app_dir, 'public'),
      :log_dir     => node["nginx"]["log_dir"],
      :appname     => app["appname"],
      :hostname    => app["hostname"],
      :servers     => [upstream_server],
      :listen_port => app["vhost_config"]["listen_port"] || 80,
      :ssl_key     => app["vhost_config"]["ssl_key"],
      :ssl_cert    => app["vhost_config"]["ssl_cert"]
    })
    notifies :reload, "service[nginx]"
  end
  nginx_site app["appname"]

  # Setup unicorn config
  unicorn_config_file = "/etc/unicorn/#{ app["appname"] }.rb"
  default_unicorn_config = {
    :listen => { upstream_port => { :tcp_nodelay => true, :backlog => 100 } },
    :working_directory => app_dir,
    :worker_timeout => 60,
    :preload_app => false,
    :worker_processes => [node[:cpu][:total].to_i * 4, 8].min,
    :preload_app => false,
    :before_fork => 'sleep 1'
  }
  app["unicorn_config"] = default_unicorn_config.merge(app["unicorn_config"] || {})
  unicorn_config unicorn_config_file do
    app["unicorn_config"].each do |key, value|
      send(key, value)
    end
  end

  # Setup runit service
  runit_service app["appname"] do
    template_name 'unicorn'
    cookbook 'rackbox'

    options(
      :user => node["appbox"]["apps_user"],
      :group => node["appbox"]["apps_user"],
      :rails_env => "production",
      :smells_like_rack => ::File.exists?(::File.join(app_dir, "config.ru")),
      :unicorn_config_file => unicorn_config_file,
      :working_directory => app_dir
    )
    run_restart false
  end

end

