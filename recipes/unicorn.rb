#
# Cookbook Name:: rackbox
# Recipe:: unicorn
#
# Setup unicorn apps
#

Array(node["rackbox"]["apps"]["unicorn"]).each_with_index do |app, index|

  upstream_port   = node["rackbox"]["upstream_start_port"]["unicorn"].to_i + index
  upstream_server = "localhost:#{upstream_port}"
  app_dir         = ::File.join(node["appbox"]["apps_dir"],
                                app["appname"], 'current')

                  Chef::Log.info("-------------------***")

  # Setup nginx virtual host
  nginx_cfg = node["rackbox"]["default_config"]["nginx"].to_hash.merge(
                  app["nginx_config"] || {})

                  Chef::Log.info(nginx_cfg.class)
                  Chef::Log.info(nginx_cfg)


  template( File.join(node["nginx"]["dir"], "sites-available", app["appname"]) ) do

    source    nginx_cfg["template_name"]
    cookbook  nginx_cfg["template_cookbook"]
    mode      "0644"
    owner     "root"
    group     "root"
    variables(
      :root_path   => ::File.join(app_dir, 'public'),
      :log_dir     => node["nginx"]["log_dir"],
      :appname     => app["appname"],
      :hostname    => app["hostname"],
      :servers     => [upstream_server],
      :listen_port => nginx_cfg["listen_port"],
      :ssl_key     => nginx_cfg["ssl_key"],
      :ssl_cert    => nginx_cfg["ssl_cert"]
    )
    notifies :reload, "service[nginx]"
  end
  nginx_site app["appname"]

  # Setup unicorn config
  unicorn_config_file = "/etc/unicorn/#{ app["appname"] }.rb"

  unicorn_cfg = node["rackbox"]["default_config"]["unicorn"].to_hash.merge(
    :listen => { 
      upstream_port => { :tcp_nodelay => true, :backlog => 100 } },
    :working_directory => app_dir
  )
  unicorn_cfg = unicorn_cfg.merge(app["unicorn_config"] || {})

  unicorn_config unicorn_config_file do
    unicorn_cfg.each do |key, value|
      send(key, value)
    end
    notifies :restart, "runit_service[#{app["appname"]}]"
  end

  # Setup runit service
  runit_cfg = node["rackbox"]["default_config"]["runit"].to_hash.merge(
                app["runit_config"] || {})

  runit_service app["appname"] do
    template_name  runit_cfg["template_name"]
    cookbook       runit_cfg["template_cookbook"]
    options(
      :user                 => node["appbox"]["apps_user"],
      :group                => node["appbox"]["apps_user"],
      :rails_env            => runit_cfg["rails_env"],
      :smells_like_rack     => ::File.exists?(::File.join(app_dir, "config.ru")),
      :unicorn_config_file  => unicorn_config_file,
      :working_directory    => app_dir
    )
    action [:enable, :restart]
  end

end

