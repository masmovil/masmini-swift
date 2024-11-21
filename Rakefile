# frozen_string_literal: true

task default: %w[setup]

task(:setup) do
end

task(:tests) do
  sh('swift test --enable-code-coverage --disable-swift-testing -v')
end
