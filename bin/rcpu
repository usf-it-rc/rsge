#!/usr/bin/env ruby

require 'rsgehost'

hosts = RsgeHost.new

hosts.each do |host|
    puts host.name + " => " + hosts.load_value("cpu")
end
