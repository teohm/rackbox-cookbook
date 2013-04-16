name             "rackbox"
maintainer       "Huiming Teo"
maintainer_email "teohuiming@gmail.com"
license          "Apache License 2.0"
description      "Setup a rack-based application server to run unicorn and passenger apps."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.2"

recipe "rackbox", "run all recipes."
recipe "rackbox::ruby", "setup a ruby version manager `rbenv`."
recipe "rackbox::nginx", "setup `nginx` as front-end server."
recipe "rackbox::unicorn", "setup `unicorn` apps, if any."
recipe "rackbox::passenger", "setup `passenger` apps, if any."

supports 'ubuntu'
supports 'debian'

depends 'appbox'
depends 'rbenv'
depends 'nginx'
depends 'unicorn', ">= 1.2.2"
depends 'runit', '>= 1.1.2'
