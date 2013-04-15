#
# Cookbook Name:: rackbox
# Recipe:: default
#

include_recipe "appbox"
include_recipe "rackbox::ruby"
include_recipe "rackbox::nginx"
include_recipe "runit"

if node["rackbox"]["apps"]["unicorn"]
  include_recipe "rackbox::unicorn"
end

if node["rackbox"]["apps"]["passenger"]
  include_recipe "rackbox::passenger"
end
