# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
  puts('➡️  Bundle 💎')
  sh('bundle install')
  
  puts('➡️  Overcommit 👮‍♀️')
  sh('bundle exec overcommit --install')
  sh('bundle exec overcommit --sign')
  sh('bundle exec overcommit --sign pre-commit')
  sh('bundle exec overcommit --sign post-checkout')

  puts('➡️  Mint 🍃')
  sh('mint bootstrap')  
end

task(:lint) do
  sh('mint run swiftlint --fix --format')
end

task(:test) do
  sh('swift test --enable-code-coverage --disable-swift-testing')
end
