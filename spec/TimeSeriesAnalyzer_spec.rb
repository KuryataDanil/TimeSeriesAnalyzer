# frozen_string_literal: true

RSpec.describe TimeSeriesAnalyzer do
  it "has a version number" do
    expect(TimeSeriesAnalyzer::VERSION).not_to be nil
  end

  describe "Reading Data" do
    it "Simple" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_simple.csv')
      expect(time_series.data).to eq([100, 200])
    end

    it "Large" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_large.csv')
      expect(time_series.data).to eq([100.00, 83.33, 66.67, 50.00, 33.33, 16.67])
    end

    it "Seasonal" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
      expect(time_series.data).to eq([100, 83, 66, 100.00, 83, 66.0])
    end
  end

  describe "Reading Timestamps" do
    it "Simple" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_simple.csv')
      timestamps = time_series.timestamps.map { |x| x.strftime('%Y-%m-%d') }
      expect(timestamps).to eq(["2023-01-01", "2023-01-02"])
    end

    it "Large" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_large.csv')
      timestamps = time_series.timestamps.map { |x| x.strftime('%Y-%m-%d') }
      expect(timestamps).to eq(["2023-01-01", "2023-02-01", "2023-03-01", "2023-04-01", "2023-05-01", "2023-06-01"])
    end
  end

  it "Moving Average" do
    time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
    expect(time_series.moving_average(3).data).to eq([nil, nil, 83.0, 83.0, 83.0, 83.0])
  end

  it "Exponential Smoothing" do
    time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
    expect(time_series.exponential_smoothing(0.3).data).to eq([100.0, 94.9, 86.23, 90.36099999999999, 88.15269999999998, 81.50688999999998])
  end
end
