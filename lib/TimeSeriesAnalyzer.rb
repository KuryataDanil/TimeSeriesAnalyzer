# frozen_string_literal: true
require 'csv'
require 'rmagick'
require 'time'
require 'matrix'
require_relative "TimeSeriesAnalyzer/version"

module TimeSeriesAnalyzer
  #Числовой ряд
  class TimeSeries
    attr_accessor :data, :timestamps

    def initialize(data, timestamps, period = -1)
      @data = data
      @timestamps = timestamps
      @period = period
    end

    #Чтение ряда из .csv файла
    def self.load_from_csv(file_path, period = -1)
      data = []
      timestamps = []
      CSV.foreach(file_path, headers: true) do |row|
        timestamps << Time.parse(row['timestamp'])
        data << row['value'].to_f
      end
      new(data, timestamps, period)
    end

    #Функция для запуска визуализации ряда в .png файл, file_name - путь к нему
    def plot(file_name = 'time_series.png', title = "")
      draw_plot(@data, @timestamps, title, file_name)
    end

    #Возращает числовой ряд, отображающий скользящее среднее исходного
    def moving_average(window_size)
      ma_data = @data.each_cons(window_size).map { |window| window.sum / window_size }
      padding = Array.new(window_size - 1, nil)
      TimeSeries.new(padding + ma_data, @timestamps)
    end

    #Возращает числовой ряд, отображающий экспоненциальное сглаживание исходного
    def exponential_smoothing(alpha)
      smoothed_data = [@data.first]
      @data.each_cons(2) do |previous, current|
        smoothed_data << alpha * current + (1 - alpha) * smoothed_data.last
      end
      TimeSeries.new(smoothed_data, @timestamps)
    end

    #Разложение ряда на тренд, сезонную компоненту и остаток
    def decompose
      trend = TrendComponent.new(@data).fit
      seasonal = SeasonalComponent.new(@data, @period).fit
      residual = @data.zip(trend, seasonal).map { |d, t, s| d - t - s }
      {
        trend: TimeSeries.new(TrendComponent.new(@data).accurate_fit, @timestamps),
        seasonal: TimeSeries.new(seasonal, @timestamps),
        residual: TimeSeries.new(residual, @timestamps)
      }
    end

    private
    #Визуализация ряда в .png файл
    def draw_plot(data, timestamps, title, file_name)
      width = 200 + timestamps.size * 50
      height = 400
      padding = 50
      plot_area_width = width - 2 * padding
      plot_area_height = height - 2 * padding

      min_value = data.compact.min.to_f
      max_value = data.compact.max.to_f
      value_range = max_value - min_value

      canvas = Magick::Image.new(width, height) {background_color = 'white' }
      draw = Magick::Draw.new

      # Draw title
      draw.annotate(canvas, 0, 0, 0, padding / 2, title) { |options|
        options.font_weight = Magick::BoldWeight
        options.pointsize = 20
        options.gravity = Magick::NorthGravity
      }

      # Draw axes
      draw.line(padding, padding, padding, height - padding)
      draw.line(padding, height - padding, width - padding, height - padding)

      # Set line width
      draw.stroke('#506DFF')
      draw.stroke_linecap('round')
      draw.stroke_width(4)
      draw.stroke_linejoin('round')

      # Draw data
      data.each_with_index.each_cons(2) do |(value1, index1), (value2, index2)|
        next if value1.nil? || value2.nil?

        x1 = padding + index1 * plot_area_width / (data.size - 1)
        y1 = height - padding - (value1 - min_value) * plot_area_height / value_range
        x2 = padding + index2 * plot_area_width / (data.size - 1)
        y2 = height - padding - (value2 - min_value) * plot_area_height / value_range

        draw.line(x1, y1, x2, y2)
      end

      # Draw labels on Y axis
      count_y = 10;
      label_interval = value_range / count_y
      (0..count_y).each do |i|
        value = (min_value + (count_y - i) * label_interval)
        y = i * plot_area_height / count_y - plot_area_height / 2
        draw.annotate(canvas, 0, 0, width - padding + 10, y, sprintf('%.2f', value)) { |options|
          options.gravity = Magick::EastGravity
          options.pointsize = plot_area_height / 33.3
        }
      end

      # Draw labels
      timestamps.each_with_index do |timestamp, index|
        x = index * plot_area_width / (timestamps.size == 1 ? 1 : timestamps.size - 1) - plot_area_width / 2
        draw.annotate(canvas, 0, 0, x, height - padding / 2, timestamp.strftime('%Y-%m-%d')) { |options|
          options.gravity = Magick::NorthGravity
          options.pointsize = 10 > plot_area_width / 144.4 ? 10 : plot_area_width / 144.4
        }
      end

      draw.draw(canvas)
      canvas.write(file_name)
    end

    class TrendComponent
      def initialize(data)
        @data = data
      end

      def fit
        # Пример использования
        x = (0...@data.size).to_a # Массив значений x (0, 1, 2, ...)
        y = @data # Массив значений y (данные)

        max_degree = x.size >= 8 ? 8 : x.size - 1
        best_degree = best_polynomial_degree(x, y, max_degree)# Степень полинома

        # Получаем коэффициенты полинома
        coefficients = polynomial_coefficients(x, y, best_degree)

        # Вычисляем значения полиномиального тренда
        polynomial_trend(x, coefficients)
      end

      def accurate_fit
        # Пример использования
        x = (0...@data.size).to_a # Массив значений x (0, 1, 2, ...)
        y = @data # Массив значений y (данные)

        max_degree = x.size >= 8 ? 8 : x.size - 1
        best_degree = best_polynomial_degree(x, y, max_degree)# Степень полинома

        # Получаем коэффициенты полинома
        coefficients = polynomial_coefficients(x, y, best_degree)

        accurate_x = (0...@data.size*10-9).map { |x| x.to_f/10 }
        # Вычисляем значения полиномиального тренда
        polynomial_trend(accurate_x, coefficients)
      end

      private

      # Функция для вычисления RMSE
      def rmse(y_true, y_pred)
        Math.sqrt(y_true.zip(y_pred).map { |y_t, y_p| (y_t - y_p)**2 }.sum / y_true.size)
      end

      # Функция для определения лучшей степени полинома
      def best_polynomial_degree(x, y, max_degree)
        best_degree = 0
        best_rmse = Float::INFINITY

        (1..max_degree).each do |degree|
          coefficients = polynomial_coefficients(x, y, degree)
          trend = polynomial_trend(x, coefficients)
          current_rmse = rmse(y, trend)

          if current_rmse < best_rmse
            best_rmse = current_rmse
            best_degree = degree
          end
        end

        best_degree
      end

      def polynomial_coefficients(x, y, degree)
        n = x.size
        x_data = Array.new(n) { Array.new(degree + 1, 0.0) }

        # Заполняем матрицу значениями x, x^2, x^3 и т.д.
        (0...n).each do |i|
          (0..degree).each do |j|
            x_data[i][j] = x[i]**j
          end
        end

        x_matrix = Matrix[*x_data]
        y_matrix = Matrix.column_vector(y)

        # Оцениваем коэффициенты полинома
        ((x_matrix.t * x_matrix).inverse * x_matrix.t * y_matrix).transpose.to_a[0]
      end

      # Функция для вычисления значений полиномиального тренда
      def polynomial_trend(x, coefficients)
        trend = Array.new(x.size, 0.0)
        x.each_with_index do |x_val, index|
          coefficients.each_with_index do |coeff, i|
            trend[index] += coeff * (x_val**i)
          end
        end
        trend
      end
    end

    class SeasonalComponent
      def initialize(data, period = -1)
        @data = data
        @period = period == -1 ? detect_period : period
      end

      def fit
        if @period == 1
          return @data.map {|| 0.0}
        end
        period_means = Array.new(@period) { |i| mean(@data.each_slice(@period).map { |slice| slice[i] }.compact) }
        @data.each_with_index.map { |_, index| period_means[index % @period] }
      end

      private

      def detect_period
        max_lag = @data.size / 2 # Максимальное значение лага
        autocorrelation = (1..max_lag).map { |lag| calculate_autocorrelation(lag) }

        # Определяем период сезонности
        autocorrelation.index(autocorrelation.max) + 1
      end

      private

      def calculate_autocorrelation(lag)
        mean = mean(@data)
        n = @data.size

        numerator = (0...n - lag).map { |i| (@data[i] - mean) * (@data[i + lag] - mean) }.sum
        denominator = (0...n).map { |i| (@data[i] - mean)**2 }.sum

        numerator / denominator
      end

      #Среднее арифметическое значений в массиве
      def mean(arr)
        arr.sum.to_f / arr.size
      end
    end


    #Среднее арифметическое значений в массиве
    def mean(arr)
      arr.sum.to_f / arr.size
    end

    #Вычисление дисперсии значений в массиве
    def variance(arr)
      m = mean(arr)
      arr.map { |v| (v - m)**2 }.sum / (arr.size - 1)
    end
  end
end
