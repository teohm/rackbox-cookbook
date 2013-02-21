#
# Cookbook Name:: rackbox
# Recipe:: default
#

include_recipe "rackbox::ruby"
include_recipe "rackbox::nginx"
include_recipe "runit"
include_recipe "rackbox::unicorn"
