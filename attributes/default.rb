default["rackbox"]["ruby"]["versions"] = %w(1.9.3-p385)
default["rackbox"]["ruby"]["global_version"] = "1.9.3-p385"
default["rackbox"]["upstream_start_port"]["unicorn"] = 10001
default["rackbox"]["upstream_start_port"]["passenger"] = 20001

default["rackbox"]["default_config"]["nginx"]["template_name"] = "nginx_vhost.conf.erb"
default["rackbox"]["default_config"]["nginx"]["template_cookbook"] = "rackbox"
default["rackbox"]["default_config"]["nginx"]["listen_port"] = "80"

default["rackbox"]["default_config"]["unicorn"]["listen_port_options"] = { :tcp_nodelay => true, :backlog => 100 }
default["rackbox"]["default_config"]["unicorn"]["worker_timeout"] = 60
default["rackbox"]["default_config"]["unicorn"]["preload_app"] = true
default["rackbox"]["default_config"]["unicorn"]["worker_processes"] = [node[:cpu][:total].to_i * 4, 8].min
default["rackbox"]["default_config"]["unicorn"]["before_fork"] = 'defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!'
default["rackbox"]["default_config"]["unicorn"]["after_fork"] = 'defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection'

default["rackbox"]["default_config"]["unicorn_runit"]["template_name"] = "unicorn"
default["rackbox"]["default_config"]["unicorn_runit"]["template_cookbook"] = "rackbox"
default["rackbox"]["default_config"]["unicorn_runit"]["rack_env"] = "production"

default["rackbox"]["default_config"]["passenger_runit"]["template_name"] = "passenger"
default["rackbox"]["default_config"]["passenger_runit"]["template_cookbook"] = "rackbox"
default["rackbox"]["default_config"]["passenger_runit"]["rack_env"] = "production"
default["rackbox"]["default_config"]["passenger_runit"]["max_pool_size"] = 6
default["rackbox"]["default_config"]["passenger_runit"]["min_instances"] = 1
default["rackbox"]["default_config"]["passenger_runit"]["spawn_method"] = "smart-lv2"
default["rackbox"]["default_config"]["passenger_runit"]["host"] = "localhost"

default["rackbox"]["apps"]["unicorn"] = []
default["rackbox"]["apps"]["passenger"] = []

set['nginx']['init_style'] = "init"

