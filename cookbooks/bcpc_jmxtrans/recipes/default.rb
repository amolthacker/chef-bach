#
# Cookbook Name:: bcpc_jmxtrans
# Recipe:: default
#
# Copyright 2014, Bloomberg L.P
#
# All rights reserved
#

chef_gem 'chef-rewind' do
  version '>0.0'
  compile_time true
end

require 'chef/rewind'

#
# Logic to include the node ip so that the JMXTrans JSON file can be genereated correctly
#
vservers = node['jmxtrans']['servers'].dup

vservers.each do |vserver|
  vserver['name']=node['bcpc']['management']['ip']
  vserver['alias']=vserver['type']+"."+node[:hostname]

  if vserver['type'] == 'resourcemanager' || vserver['type'] == 'nodemanager'
    vserver['port']=node[:bcpc][:hadoop][:yarn][vserver['type']][:jmx][:port]
  else
    vserver['port']=node["bcpc"]["hadoop"][vserver['type']]["jmx"]["port"]
  end
end

node.override['jmxtrans']['servers']=vservers

#
# Logic to populate the graphite parameters if they are not set
#

if node['jmxtrans']['graphite']['host'].nil? || node['jmxtrans']['graphite']['host'] == 'graphite'
  node.default['jmxtrans']['graphite']['host'] = node['bcpc']['management']['vip']

end

if node.default['jmxtrans']['graphite']['port'] != node['bcpc']['graphite']['relay_port']
   node.default['jmxtrans']['graphite']['port'] = node['bcpc']['graphite']['relay_port']
end

#
# The JMXtrans cookbook expects to talk to Maven Central with a
# remote_file resource, so we will need a proxy configuration on
# internet-connected clients.
#
include_recipe 'bcpc::proxy_configuration'

include_recipe 'jmxtrans'

#
# The jmxtrans cookbook v2.0 omits a checksum on its ark
# resource, so we rewind it to re-add it.
#
rewind 'ark[jmxtrans]' do
  checksum node['jmxtrans']['checksum']
end

#
# Get an array of hosts which are graphite heads
#
graphite_hosts_ips = get_head_nodes.map{|x| x[:ip_address]}
#
# Array to store the list of services on which jxmtrans dependent on i.e. collects data from
# If any of the services gets restarted jmxtrans process need to be restarted
#
jmx_services = Array.new
jmx_service_cmds = Hash.new
#
# If the current host is a graphite head add the carbon processes to the list of services array
#
graphite_hosts_ips.each do |host|
  if host == node['bcpc']['management']['ip']
    jmx_services.push("carbon-relay")
    jmx_services.push("carbon-cache")
    jmx_service_cmds["carbon-relay"] = "carbon-relay.py"
    jmx_service_cmds["carbon-cache"] = "carbon-cache.py"
    break
  end
end
#
# Add services of processes on this node from which jmx data are collected by jmxtrans
#
node['jmxtrans']['servers'].each do |server|
  jmx_services.push(server['service'])
  jmx_service_cmds[server['service']] = server['service_cmd']
end

#
# Ruby block to restart jmxtrans if any of the dependent process is restarted
#
service "restart jmxtrans on dependent service" do
  service_name "jmxtrans"
  supports :restart => true, :status => true, :reload => true
  action   :restart
  #
  # Using the services array generate chef service resources to restart when the monitored services are restarted
  #
  jmx_services.each do |jmx_dep_service|
    subscribes :restart, "service[#{jmx_dep_service}]", :delayed
  end
  # Run if we see a service was restarted (either manually or from a service restart subscribed above)
  only_if { process_require_restart?("jmxtrans","jmxtrans-all.jar",jmx_service_cmds) }
end
