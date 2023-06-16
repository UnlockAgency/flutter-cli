#!/usr/bin/env ruby
script = `git archive --remote=git@gitlab.e-sites.nl:team-i/flutter/Scripts.git HEAD flutter.rb | tar -xO`
eval(script)