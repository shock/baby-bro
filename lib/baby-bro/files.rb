require 'time'
require 'fileutils'

module BabyBro
  module Files
    def file_timestamp(filename)
      File.mtime(filename)
    end

    def touch_file(filename, time)
      # `touch -t #{time.strftime("%Y%m%d%H%M.%S")} #{filename}`
      FileUtils.touch(filename, mtime: time)
    end

    # returns files in the specified directory
    def find_files(directory, pattern='*')
      # `find -H '#{directory}' -name "#{pattern}"`.split("\n").reject{|f| f==directory}
      Dir.glob(File.join(directory, '**', pattern)) - [directory]
    end

    # returns files in the specified directory that are newer than the specified file
    def find_files_newer_than_file(directory, filename)
      # `find -H '#{directory}' -newer #{filename}`.split("\n")
      reference_time = File.mtime(filename)
      results = Dir.glob(File.join(directory, '**', '{*,.*}')).select do |f|
        File.file?(f) && File.mtime(f) > reference_time
      end
      results
    end

    # returns files in the specified directory that are newer than the time expression
    # time_interval_expression is in english, eg. "15 minutes"
    def find_recent_files(directory, time_interval_expression)
      # `find -H '#{directory}' -newermt "#{time_interval_expression} ago"`.split("\n")
      reference_time = parse_time_expression(time_interval_expression)
      Dir.glob(File.join(directory, '**', '{*,.*}')).select do |f|
        File.file?(f) && File.mtime(f) > reference_time
      end
    end

    private

    def parse_time_expression(expression)
      amount, unit = expression.split
      amount = amount.to_i
      Time.now - case unit.downcase
                 when 'minute', 'minutes' then amount * 60
                 when 'hour', 'hours' then amount * 3600
                 when 'day', 'days' then amount * 86400
                 else raise ArgumentError, "Unsupported time unit: #{unit}"
                 end
    end
  end
end