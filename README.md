# TimeSeriesAnalyzer

[![Testing](https://github.com/sinatra/sinatra/actions/workflows/test.yml/badge.svg)](https://github.com/KuryataDanil/TimeSeriesAnalyzer/actions/workflows/main.yml)

TimeSeriesAnalyzer is designed for solving and visualizing numerical series

## Installation

```shell
gem install TimeSeriesAnalyzer
```

## Usage

Uploading data from a CSV file:
```ruby
time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv(file_path)
# the second variable "period" determines the seasonality of the data
# by default -1, which means the seasonality is determined automatically
```

Visualization of a time series:
```ruby
time_series.plot(file_name)
# the second variable "title" indicates the title of the graph
```

Decomposition of a time series:
```ruby
decomposed = time_series.decompose

print(decomposed[:trend].data) # trend
puts ""
print(decomposed[:seasonal].data) # seasonal component
puts ""
print(decomposed[:residual].data) # remains
puts ""

decomposed[:trend].plot('trend.png')
decomposed[:seasonal].plot('seasonal.png')
decomposed[:residual].plot('residual.png')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KuryataDanil/TimeSeriesAnalyzer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KuryataDanil/TimeSeriesAnalyzer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TimeSeriesAnalyzer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/TimeSeriesAnalyzer/blob/master/CODE_OF_CONDUCT.md).
