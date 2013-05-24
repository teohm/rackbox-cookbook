#
# Cookbook Name:: rackbox
# Recipe:: default
#

include_recipe "appbox"
include_recipe "rackbox::ruby"
include_recipe "rackbox::nginx"
include_recipe "runit"

if node["rackbox"]["apps"]["unicorn"].any?
  include_recipe "rackbox::unicorn"
end

if node["rackbox"]["apps"]["passenger"].any?
  include_recipe "rackbox::passenger"
end
