# TimeSeriesAnalyzer

[![Testing](https://github.com/sinatra/sinatra/actions/workflows/test.yml/badge.svg)](https://github.com/KuryataDanil/TimeSeriesAnalyzer/actions/workflows/main.yml)

TimeSeriesAnalyzer is designed for solving and visualizing numerical series

## Installation

```shell
gem install TimeSeriesAnalyzer
```

The rmagick gem must be installed for it to work properly https://imagemagick.org/script/download.php#windows

<img width="75%" src="https://github.com/rmagick/rmagick/assets/199156/494e7963-cca5-4cb5-b28a-6c4d76adce5d" />

Then you need to go to the project terminal
```shell
set CPATH="C:\Program Files (x86)\ImageMagick-[VERSION]-Q16\include"
set LIBRARY_PATH="C:\Program Files (x86)\ImageMagick-[VERSION]-Q16\lib"
em install rmagick 
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

Application of the moving average:
```ruby
moving_average(window_size)
#Returns a numeric series representing the moving average of the original
#parameter window_size is the size


smoothed_series = time_series.moving_average(3)
print(smoothed_series.data)
puts ""
smoothed_series.plot('moving_average.png')
```

Applying exponential smoothing:
```ruby
exponential_smoothing(alpha)
#Returns a numeric series representing the exponential smoothing of the original one
#The value of alpha represents the smoothing factor, which determines the weight of the current
#observation compared to the smoothed previous value.


smoothed_series = time_series.exponential_smoothing(0.3)
print(smoothed_series.data)
puts ""
smoothed_series.plot('exponential_smoothing.png')
```

Anomaly detection:
```ruby
detect_anomalies
#Function that returns detected anomalies in the numeric series
#Anomalies found are returned as dictionaries with timestamps and values.

anomalies = time_series.detect_anomalies
anomalies.each { |anomaly| puts "Anomaly detected at #{anomaly[:timestamp]}: #{anomaly[:value]}" }
```

Forecasting:
```ruby
forecast(steps)
#Function that predicts the following values (prediction based on the subsequent change of residues only)
#steps - number of steps for which it is necessary to forecast

forecasted_values = time_series.forecast(10)
puts "Forecasted values: #{forecasted_values}"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KuryataDanil/TimeSeriesAnalyzer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KuryataDanil/TimeSeriesAnalyzer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TimeSeriesAnalyzer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/TimeSeriesAnalyzer/blob/master/CODE_OF_CONDUCT.md).
