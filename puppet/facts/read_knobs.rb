#!/usr/bin/ruby
#
# fact returns knob values based on contents of /etc/knobs.
#
# Author: jpb@ooyala.com
#
# Copyright 2009 Ooyala, Inc.
# License: BSD

require 'facter'

def logger(message)
  system("/usr/bin/logger -t read_knobs #{message}")
end

# facts can only have one value. We ignore lines with shell style comments,
# and return the last valid line.

def read_knob(filename)
  knob_name = filename.split('/')[-1]
  knob_file = File.open(filename)
  # an empty knob file must have been created for a reason, so set default
  # value to true
  value = true
  knob_file.each { |line|
    if line[0,1] != "#"
      if (line.downcase.chomp == "true") or (line.downcase.chomp == "t")
        value = true
      elsif (line.downcase.chomp == "false") or (line.downcase.chomp == "f")
        value = false
      else
        value = line.chomp
      end
    end
  }
  knob_file.close
  value
end

def load_knobs(knob_d)
  logger "Processing #{knob_d}..."
  if ! File.directory?(knob_d)
    logger("Can't read #{knob_d}!")
    return nil
  end
  Dir["#{knob_d}/*"].each do |knob|
    if File.readable?(knob)
      knob_name = knob.split('/')[-1]
      Facter.add("#{knob_name}") do
        setcode do
          data = read_knob(knob)
          data
        end
      end
    else
      logger("Can't read #{knob}!")
    end
  end
end

load_knobs('/etc/knobs')