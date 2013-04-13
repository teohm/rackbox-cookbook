module Rackbox
  module Helpers
    def unicorn_config_filepath(appname)
      "/etc/unicorn/#{ appname }.rb"
    end

    def setup_passenger_runit(app, app_dir, default_port)
      default_config =  node["rackbox"]["default_config"]["passenger_runit"].to_hash
      default_config["port"] = default_port
      config = merge_runit_config(
        default_config,
        app["runit_config"]
      )
      runit_service app["appname"] do
        run_template_name  config["template_name"]
        log_template_name  config["template_name"]
        cookbook       config["template_cookbook"]
        options(
          :user              => node["appbox"]["apps_user"],
          :group             => node["appbox"]["apps_user"],
          :rack_env          => config["rack_env"],
          :working_directory => app_dir,
          :socket            => config["socket"],
          :host              => config["host"],
          :port              => config["port"],
          :max_pool_size     => config["max_pool_size"],
          :min_instances     => config["min_instances"],
          :spawn_method      => config["spawn_method"]
        )
        restart_on_update false
      end
    end

    def setup_unicorn_runit(app, app_dir)
      config = merge_runit_config(
        node["rackbox"]["default_config"]["unicorn_runit"],
        app["runit_config"]
      )
      unicorn_config_file = unicorn_config_filepath(app["appname"])

      runit_service app["appname"] do
        run_template_name  config["template_name"]
        log_template_name  config["template_name"]
        cookbook       config["template_cookbook"]
        options(
          :user                 => node["appbox"]["apps_user"],
          :group                => node["appbox"]["apps_user"],
          :rack_env            => config["rack_env"],
          :smells_like_rack     => true, #::File.exists?(::File.join(app_dir, "config.ru")),
          :unicorn_config_file  => unicorn_config_file,
          :working_directory    => app_dir
        )
        restart_on_update false
      end
    end

    def merge_runit_config(default_config, app_config)
      config = default_config.to_hash
      config.merge(app_config || {})
    end

    def setup_nginx_site(app, app_dir, upstream_port)
      upstream_server = "localhost:#{upstream_port}"
      config = merge_nginx_config(
        node["rackbox"]["default_config"]["nginx"],
        app["nginx_config"]
      )

      template( File.join(node["nginx"]["dir"], "sites-available", app["appname"]) ) do
        source    config["template_name"]
        cookbook  config["template_cookbook"]
        mode      "0644"
        owner     "root"
        group     "root"
        variables(
          :root_path   => ::File.join(app_dir, 'public'),
          :log_dir     => node["nginx"]["log_dir"],
          :appname     => app["appname"],
          :hostname    => app["hostname"],
          :servers     => [upstream_server],
          :listen_port => config["listen_port"],
          :ssl_key     => config["ssl_key"],
          :ssl_cert    => config["ssl_cert"]
        )
        notifies :reload, "service[nginx]"
      end

      # TODO issue: nginx not reload enabled site
      nginx_site app["appname"] do
        notifies :reload, "service[nginx]"
      end
    end

    def merge_nginx_config(default_config, app_config)
      config = default_config.to_hash
      config.merge(app_config || {})
    end

    def setup_unicorn_config(app, app_dir, default_port)
      config = merge_unicorn_config(
        node["rackbox"]["default_config"]["unicorn"],
        app["unicorn_config"],
        app_dir,
        default_port
      )

      unicorn_config unicorn_config_filepath(app["appname"]) do
        config.each do |key, value|
          send(key, value)
        end
        notifies :restart, "runit_service[#{app["appname"]}]"
      end
    end

    def merge_unicorn_config(default_config, app_config, app_dir, upstream_port)
      config = default_config.to_hash
      port_options = config.delete("listen_port_options")

      config = config.merge(
        :listen => { upstream_port => port_options },
        :working_directory => app_dir
      )
      config.merge(app_config || {})
    end
  end

end
