# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
require "yabeda/prometheus/mmap"

use Yabeda::Prometheus::Exporter

run Rails.application
Rails.application.load_server
