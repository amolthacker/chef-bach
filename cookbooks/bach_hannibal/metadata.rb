name             'bach_hannibal'
maintainer       'Bloomberg Finance L.P.'
maintainer_email 'hadoop@bloomberg.net'
description      'Recipes to setup pre-requisites, build and install hannibal on cluster'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "bcpc-hadoop"
supports "ubuntu"
