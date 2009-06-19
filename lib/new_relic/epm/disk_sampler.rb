#!/usr/bin/ruby
require 'new_relic/agent'

# This is some demo code which shows how you might install your
# own sampler.  This one theoretically monitors cpu.

class NewRelic::EPM::DiskSampler < NewRelic::Agent::Sampler
  case RUBY_PLATFORM 
  when /darwin/
    # Do some special stuff...
  when /linux/
    # Do some special stuff...
  else
    NewRelic::EPM::CLI.log.warn "unsupported platform #{RUBY_PLATFORM}"
  end

  def initialize
    super 'disk_sampler'
    @disk_stats = {}
  end

  def disk_stats(filesystem)
    name = File.basename(filesystem)
    @disk_stats[name] ||= stats_engine.get_stats("Custom/Filesystem/#{name}/percent", false)
  end

  # This gets called every 10 seconds, or once a minute depending
  # on how you add the sampler to the stats engine.
  # It only looks at fs partitions beginning with '/'
  def poll
    stats = `df -k`
    stats.each_line do | line |
      if line =~ /^(\/[^\s]+)\s.*\s(\d+)%/
        name = $1; alloc = $2
        disk_stats(name).record_data_point alloc.to_i
      end
    end
  end
end




