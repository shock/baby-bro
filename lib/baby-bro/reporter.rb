%w(project base_config).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Reporter
    include BaseConfig
    attr_accessor :data_directory, :projects, :config

    def initialize( options, args )
      @config = HashObject.new( process_base_config( options ) )
      process_reporting_config( @config )
      initialize_database
    end
    
    def run
      @projects.each do |project|
        print_project_report( project )
      end
    end
    
    private
      def process_reporting_config( config )
      end
      
      def print_project_report( project, date=nil )
        $stdout.puts
        $stdout.puts "#{project.name}"
        $stdout.puts "="*project.name.size
        cumulative_time = 0
        sessions = project.sessions
        if sessions.any?
          sessions_by_date = sessions.group_by(&:start_date)
          sessions_by_date.keys.sort.each do |date|
            sessions = sessions_by_date[date].sort
            $stdout.puts "  #{date.strftime("%Y-%m-%d")}"
            sessions.each do |session|
              $stdout.puts "      #{session.start_time.strftime("%I:%M %p")} - #{session.duration_in_english}"
              cumulative_time += session.duration
            end
            $stdout.puts "    Total:  #{Session.duration_in_english(sessions.inject(0){|sum,n| sum = sum+n.duration})}"
          end
          $stdout.puts "Grand Total: #{Session.duration_in_english(cumulative_time)}"
        else
          $stdout.puts "  No sessions for this project."
        end
      end
  end
end