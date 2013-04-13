name             "rackbox"
maintainer       "Huiming Teo"
maintainer_email "teohuiming@gmail.com"
license          "MIT License"
description      "Installs/Configures rackbox"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends 'appbox'
depends 'rbenv'
depends 'nginx'
depends 'unicorn', ">= 1.2.2"
depends 'runit', '>= 1.1.2'
