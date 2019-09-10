# frozen_string_literal: true

task default: %w[setup]

task(:setup) do

  raise '`brew` is required. Please install brew. https://brew.sh/' unless system('which brew')

  puts('➡️  Bundle')
  sh('brew bundle')
  sh('bundle install')

  puts('➡️  Overcommit')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')
  sh('bundle exec overcommit --sign post-checkout')

  puts('➡️  SPM Resolve Dependencies')
  sh('swift package resolve')
end

task(:build) do
  sh('swift build')
end

task(:test) do
  sh('swift test')
end