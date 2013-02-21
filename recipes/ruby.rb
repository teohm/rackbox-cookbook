#
# Cookbook Name:: rackbox
# Recipe:: ruby
#
# Install and setup Ruby environment
#

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

node["rackbox"]["ruby"]["versions"].each do |rb_version|

  rbenv_ruby rb_version do
    global(node["rackbox"]["ruby"]["global_version"] == rb_version)
  end
  rbenv_gem "bundler" do
    ruby_version rb_version
  end

end
