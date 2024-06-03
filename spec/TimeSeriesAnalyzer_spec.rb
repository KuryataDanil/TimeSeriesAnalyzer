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

  describe "Decompose" do
    describe "Simple" do
      it "Trend" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_simple.csv')
        d = time_series.decompose
        expect(d[:trend].data).to eq([100.0, 110.0, 120.0, 130.0, 140.0, 150.0, 160.0, 170.0, 180.0, 190.0, 200.0])
      end

      it "Seasonal" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_simple.csv')
        d = time_series.decompose
        expect(d[:seasonal].data).to eq([0, 0])
      end

      it "Residual" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_simple.csv')
        d = time_series.decompose
        expect(d[:residual].data).to eq([0.0, 0.0])
      end
    end

    describe "Large" do
      it "Trend" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_large.csv')
        d = time_series.decompose
        expect(d[:trend].data).to eq([100.0, 98.3308766225, 96.66246591999999, 94.99466351749999, 93.32737343999999, 91.6605078125, 89.99398655999997, 88.32773710749998, 86.66169407999998, 84.99579900249996, 83.32999999999996, 81.66425149749993, 79.99851391999991, 78.33275339249988, 76.66694143999986, 75.00105468749982, 73.33507455999981, 71.66898698249976, 70.0027820799997, 68.33645387749968, 66.66999999999963, 65.00342137249953, 63.33672191999947, 61.669908267499395, 60.002989439999304, 58.3359765624992, 56.66888255999908, 55.00172185749896, 53.334510079998836, 51.66726375249868, 49.99999999999851, 48.33273624749833, 46.66548991999812, 44.998278142497924, 43.33111743999769, 41.66402343749743, 39.99701055999715, 38.33009173249685, 36.66327807999653, 34.99657862749616, 33.32999999999579, 31.663546122495386, 29.997217919994945, 28.331013017494474, 26.664925439993947, 24.998945312493422, 23.333058559992843, 21.667246607492224, 20.00148607999156, 18.335748502490837, 16.6699999999901])
      end

      it "Seasonal" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_large.csv')
        d = time_series.decompose
        expect(d[:seasonal].data).to eq([0, 0, 0, 0, 0, 0])
      end

      it "Residual" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_large.csv')
        d = time_series.decompose
        expect(d[:residual].data).to eq([0.0, 4.263256414560601e-14, 3.694822225952521e-13, 1.4921397450962104e-12, 4.206412995699793e-12, 9.901413022816996e-12])
      end
    end

    describe "Seasonal" do
      it "Trend" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
        d = time_series.decompose
        expect(d[:trend].data).to eq([100.0, 107.84658800000001, 112.002816, 113.17375899999999, 111.99411200000002, 109.03125000000001, 104.788288, 99.70714100000001, 94.17158399999998, 88.51031199999998, 82.99999999999996, 77.868363, 73.29721599999989, 69.42553399999989, 66.35251199999986, 64.14062499999983, 62.81868799999981, 62.38491599999975, 62.80998399999974, 64.04008699999956, 65.99999999999949, 68.59613799999944, 71.71961599999955, 75.24930899999927, 79.05491199999878, 82.99999999999875, 86.9450879999988, 90.7506909999986, 94.28038399999826, 97.40386199999818, 99.99999999999784, 101.95991299999798, 103.1900159999982, 103.61508399999855, 103.18131199999743, 101.85937499999704, 99.64748799999711, 96.57446599999525, 92.70278399999597, 88.13163699999495, 82.99999999999454, 77.48968799999375, 71.82841599999347, 66.29285899999104, 61.211711999993895, 56.968749999991815, 54.0058879999915, 52.82624099998884, 53.99718399998619, 58.15341199998602, 65.99999999998727])
      end

      it "Seasonal" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
        d = time_series.decompose
        expect(d[:seasonal].data).to eq([100.0, 83.0, 66.0, 100.0, 83.0, 66.0])
      end

      it "Residual" do
        time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
        d = time_series.decompose
        expect(d[:residual].data).to eq([-100.0, -82.99999999999996, -65.99999999999949, -99.99999999999784, -82.99999999999454, -65.99999999998727])
      end
    end
  end

  it "Forecast" do
    time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
    forecasted_values = time_series.forecast(10)
    expect(forecasted_values).to eq [69.09522891566422, 72.04529961859565, 74.85701965269419, 77.53687730569736, 80.09105658146657, 82.52545147011224, 84.84567954888698, 87.057094945232, 89.16480069189043, 91.17366050259781]
  end

  describe "Anomalies" do
    it "Exist" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_anomaly.csv')
      anomalies = time_series.detect_anomalies
      expect(anomalies.size).to eq 1
      expect(anomalies[0][:timestamp].strftime('%Y-%m-%d')).to eq "2023-12-01"
      expect(anomalies[0][:value]).to eq 0
    end

    it "0 anomalies" do
      time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
      anomalies = time_series.detect_anomalies
      expect(anomalies.size).to eq 0
    end
  end

  #it "Draw Series" do
  #  time_series = TimeSeriesAnalyzer::TimeSeries.load_from_csv('spec/files for tests/data_test_season.csv')
  #  time_series.plot("spec/files for tests/test_output.png")
  #end
end
