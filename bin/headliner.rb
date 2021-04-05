#!/usr/bin/env ruby
require_relative '../lib/nodes'

root = Menu.load([__dir__, '../config/locations.txt'].join('/'))
root.activate
