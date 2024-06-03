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


      x_correction = timestamps.size.to_f / data.size
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
  end
end
