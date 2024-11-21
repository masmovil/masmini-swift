# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  puts('➡️  Bundle')
  sh('bundle install')

  puts('➡️  Overcommit')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')
end

task(:tests) do
  sh('swift test --enable-code-coverage --disable-swift-testing -v')
end
