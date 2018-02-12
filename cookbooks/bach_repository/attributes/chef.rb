default['bach']['repository']['chefdk']['url'] = \
  'https://packages.chef.io/files/stable/chefdk/2.4.17/ubuntu/' \
  '14.04/chefdk_1.6.11-1_amd64.deb'
default['bach']['repository']['chefdk']['sha256'] = \
  'a89f0ef2a8edbefbbf4cb14d8d97f83e9227fff35f2d80fb45b03604c91a207b'
default['bach']['repository']['chef']['url'] = \
  'https://packages.chef.io/repos/apt/stable/ubuntu/' \
  '14.04/chef_12.21.31-1_amd64.deb'
default['bach']['repository']['chef']['sha256'] = \
  '61656daa5f22ea31a93b602a88be196b0cc7033b1674f1bd195e4b679a1784a7'
# it does not appear that there is a 14.04 version of the ancient Chef-Server we use
default['bach']['repository']['chef_server']['url'] = \
  'https://packages.chef.io/files/stable/chef-server/12.17.15/' \
  'ubuntu/14.04/chef-server-core_12.17.15-1_amd64.deb'
default['bach']['repository']['chef_server']['sha256'] = \
  '573c855ef7e8aed9feaebedf6a58c024730f835db5559ffef16f58b7141faed2'
default['bach']['repository']['chef_url_base'] = 'https://packages.chef.io/repos/apt/stable/ubuntu/14.04/'
