# Chef cookbook - rackbox (v0.1.2)

Setup a **Rack-based application server** to run Unicorn & Passenger apps.

It performs the following tasks when setup the server:

 * setup a ruby version manager (now using `rbenv`).
 * setup `nginx` as front-end server.
 * setup `runit` service.
 * setup Unicorn apps (if any).
 * setup Passenger apps (if any).

## Install

To install with **Berkshelf**, add this into `Berksfile`:

```
cookbook 'appbox'
```

And overwrite attributes to customize the cookbook.

See also [teohm/kitchen-sample](https://github.com/teohm/kitchen-example) for `rackbox` usage example with chef-solo.

# Attributes

You **should** specify the ruby versions to be installed:

 * `node["rackbox"]["ruby"]["versions"]` (default: `["1.9.3-p385"]`) - ruby versions to be installed.
 * `node["rackbox"]["ruby"]["global_version"]` (default: `"1.9.3-p385"`) - set the system-wide ruby version.
 
To setup **unicorn apps**, provide a list of unicorn app entries:

 * `node["rackbox"]["apps"]["unicorn"]` (default: `[]`)
 
   ```
   # Example:
   node["rackbox"]["apps"]["unicorn"] = [
     {
       "appname" => "app1",            # app name
       "hostname" => "app1.test.com"   # domain name
     },
     {
       "appname" => "app2",            # app name
       "hostname" => "app2.test.com",  # domain name
       "nginx_config" => {             # overwrite default config:
         ...                           #   node["rackbox"]["default_config"]["nginx"]
       },
       "runit_config" => {             # overwrite default config:
         "rack_env" => "staging"       #   node["rackbox"]["default_config"]["unicorn_runit"]
       }
     }
   ]
   ```

To setup **passenger apps**, provide a list of passenger app entries:

 * `node["rackbox"]["apps"]["passenger"]` (default: `[]`)
 
   ```
   # Example:
   node["rackbox"]["apps"]["passenger"] = [
     {
       "appname" => "app3",            # app name
       "hostname" => "app3.test.com"   # domain name
     },
     {
       "appname" => "app4",            # app name
       "hostname" => "app4.test.com",  # domain name
       "nginx_config" => {             # overwrite default config:
         ...                           #   node["rackbox"]["default_config"]["nginx"]
       },
       "runit_config" => {             # overwrite default config:
         "rack_env" => "staging"       #   node["rackbox"]["default_config"]["passenger_runit"]
       }
     }
   ]
   ```

You may change the **default config** settings:

 * **nginx**:
   * `node["rackbox"]["default_config"]["nginx"]["template_name"]` (default: `"nginx_vhost.conf.erb"`) - nginx vhost/site config template.
   * `node["rackbox"]["default_config"]["nginx"]["template_cookbook"]` (default: `"rackbox"`) - cookbook containing the nginx vhost/site config template.
   * `node["rackbox"]["default_config"]["nginx"]["listen_port"]` (default: `"80"`) - nginx vhost/site listen port.
   * `node["rackbox"]["upstream_start_port"]["unicorn"]` (default: `10001`) - start number for unicorn app listen port.
   * `node["rackbox"]["upstream_start_port"]["passenger"]` (default: `20001`) - start number for passenger app listen port.
 * **unicorn**:
   * `node["rackbox"]["default_config"]["unicorn"]["listen_port_options"]` (default: `{ :tcp_nodelay => true, :backlog => 100 }`) - unicorn listen port options.
   * `node["rackbox"]["default_config"]["unicorn"]["worker_timeout"]` (default: `60`) - unicorn worker timeout.
   * `node["rackbox"]["default_config"]["unicorn"]["preload_app"]` (default: `false`) - unicorn preload app flag.
   * `node["rackbox"]["default_config"]["unicorn"]["worker_processes"]` (default: `[node[:cpu][:total].to_i * 4, 8].min`) - total unicorn worker.
   * `node["rackbox"]["default_config"]["unicorn"]["before_fork"]` (default: `'sleep 1'`) - unicorn before_fork handler.
 * **unicorn_runit**:
   * `node["rackbox"]["default_config"]["unicorn_runit"]["template_name"]` (default: `"unicorn"`) - name to lookup unicorn runit templates (templates: `"sv-#{template_name}-run.erb"`, `"sv-#{template_name}-log-run.erb`).
   * `node["rackbox"]["default_config"]["unicorn_runit"]["template_cookbook"]` (default: `"rackbox"`) - cookbook containing the templates.
   * `node["rackbox"]["default_config"]["unicorn_runit"]["rack_env"]` (default: `"production"`) - default RACK_ENV to run a unicorn app.
 * **passenger_runit**:
   * `node["rackbox"]["default_config"]["passenger_runit"]["template_name"]` (default: `"passenger"`) - name to lookup passenger runit templates (templates: `"sv-#{template_name}-run.erb"`, `"sv-#{template_name}-log-run.erb`).
   * `node["rackbox"]["default_config"]["passenger_runit"]["template_cookbook"]` (default: `"rackbox"`) - cookbook containing the  templates.
   * `node["rackbox"]["default_config"]["passenger_runit"]["rack_env"]` (default: `"production"`) - default RACK_ENV to run a passenger app.
   * `node["rackbox"]["default_config"]["passenger_runit"]["max_pool_size"]` (default: `6`) - passenger max pool size.
   * `node["rackbox"]["default_config"]["passenger_runit"]["min_instances"]` (default: `1`) - passenger min instance.
   * `node["rackbox"]["default_config"]["passenger_runit"]["spawn_method"]` (default: `"smart-lv2"`) - passenger spawn method.
   * `node["rackbox"]["default_config"]["passenger_runit"]["host"]` (default: `"localhost"`) - passenger host.

## Recipes

 * `rackbox::default` - run all recipes.
 * `rackbox::ruby` - setup a ruby version manager `rbenv`.
 * `rackbox::nginx` - setup `nginx` as front-end server.
 * `rackbox::unicorn` - setup `unicorn` apps, if any.
 * `rackbox::passenger` - setup `passenger` apps, if any.

## Requirements

### Supported Platforms

 * `ubuntu` - tested on Ubuntu 12.10
 * `debian` - should work
 
Pull requests, issue and test reports are welcomed to better support your platform.
 
### Cookbook Dependencies

 * Depends on these cookbooks:
   * appbox
   * rbenv
   * nginx
   * unicorn (>= 1.2.2)
   * runit (>= 1.1.2)

## License and Authors

 * Author:: Huiming Teo <teohuiming@gmail.com>

Copyright 2013, Huiming Teo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
