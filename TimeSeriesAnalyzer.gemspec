# frozen_string_literal: true

require_relative "lib/TimeSeriesAnalyzer/version"

Gem::Specification.new do |spec|
  spec.name = "TimeSeriesAnalyzer"
  spec.version  = '0.1.0'
  spec.authors = ["KuryataDanil"]

  spec.summary = "TimeSeriesAnalyzer is designed for solving and visualizing numerical series"
  spec.homepage = "https://github.com/KuryataDanil/TimeSeriesAnalyzer"
  spec.license = "MIT"

  spec.files         = Dir['lib/**/*', 'README.md']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec'
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
