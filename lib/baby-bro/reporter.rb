%w(project base_config).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro

  class ProjectDateReport
    attr :project, :date, :sessions, :cumulative_time
    def initialize( project, sessions, date )
      @project = project
      @date = date
      @cumulative_time = 0
      @sessions = sessions
      process_sessions
    end

    def process_sessions
      @sessions.each do |session|
        @cumulative_time += session.duration
      end
    end

  end

  class ProjectReport
    attr_accessor :project, :cumulative_time, :sessions, :reports_by_date

    def initialize( project, report_date=nil )
      @project = project
      @report_date = report_date
      @cumulative_time = 0
      @reports_by_date = HashObj.new({})
      @sessions_by_date = HashObj.new({})
      process_sessions
    end

    def is_active?; return @sessions.any?; end

    private

    def process_sessions
      sessions = @sessions = @project.sessions
      report_date = @report_date

      if sessions.any?
        @sessions_by_date = sessions.group_by(&:start_date)

        if report_date
          if @sessions_by_date[report_date]
            @reports_by_date[report_date] = ProjectDateReport.new( @project, @sessions_by_date[report_date], report_date )
            @cumulative_time = @reports_by_date[report_date].cumulative_time
          end
          return
        end

        @sessions_by_date.keys.sort.each do |date|
          sessions = @sessions_by_date[date].sort
          @reports_by_date[date] = ProjectDateReport.new( @project, sessions, date )
        end
      end
      @cumulative_time = @reports_by_date.values.inject(0){|sum,n| sum = sum+n.cumulative_time}
    end

  end

  class Report
    attr :cumulative_time, :project_reports, :projects, :reports_by_project
    def initialize( projects, report_date= nil )
      @projects = projects
      project_reports = @projects.map{|p| ProjectReport.new(p, report_date)}
      @cumulative_time = project_reports.inject(0){|sum,n| sum = sum+n.cumulative_time}
      @project_reports = project_reports
      @reports_by_project = HashObj.new({})
      @project_reports.each do |pr|
        @reports_by_project[pr.project] = pr
      end
    end
  end

  class Reporter
    include BaseConfig
    attr_accessor :data_directory, :projects, :config

    def initialize( options, args )
      @config = HashObj.new( process_base_config( options ) )
      @brief = @config.brief
      process_reporting_config( @config )
      initialize_database
      date_string = args.shift
      if date_string == 'today'
        @date = Date.today
      elsif date_string == 'yesterday'
        @date = Date.today - 1
      elsif date_string
        begin
          @date = Date.parse(date_string)
        rescue
          @date = Date.today - date_string.to_i
        end
      end
      @report = Report.new( @projects, @date )
    end

    def run
      if @brief && @date
        $stdout.puts
        $stdout.puts "#{@date.strftime("%Y-%m-%d")}:"
      end
      @longest_project_name = @projects.inject(0){|max,p| p.name.size>max ? p.name.size : max}
      @total_time = 0
      @projects.sort_by{|p| p.last_activity}.each do |project|
        print_project_report( @report.reports_by_project[project], @date )
      end
      puts "\n--------------------------------------------------------------------------------"
      puts "Total Time: #{Session.duration_in_english(@report.cumulative_time)}"
      puts
    end


    private
      def process_reporting_config( config )
      end

      def print_project_report( project_report, report_date=nil )
        project = project_report.project
        return if @brief && !project_report.is_active?

        if @brief && report_date
          $stdout.puts
          $stdout.print "  #{project.name}#{" "*(@longest_project_name - project.name.size)}  :"
        else
          $stdout.puts
          $stdout.puts "#{project.name}"
          $stdout.puts "="*project.name.size
        end

        if project_report.is_active?
          reports_by_date = project_report.reports_by_date
          has_sessions_for_date = false
          reports_by_date.keys.sort.each do |date|
            next if report_date && date != report_date
            sessions = reports_by_date[date].sessions.sort
            $stdout.puts "  #{date.strftime("%Y-%m-%d")}" unless @brief && report_date
            sessions.each do |session|
              $stdout.puts "      #{session.start_time.strftime("%I:%M %p")} - #{session.end_time.strftime("%I:%M %p")}  ~ #{session.duration_in_english}" unless @brief
            end
            has_sessions_for_date = true
            $stdout.print "    Total:" unless @brief && report_date
            sessions_time = project_report.reports_by_date[date].cumulative_time
            $stdout.puts "  #{Session.duration_in_english(sessions_time)}"
            $stdout.puts unless @brief
          end
          unless has_sessions_for_date
            $stdout.print "   no activity" if @brief
            puts
          end
          $stdout.puts "  Project Total: #{Session.duration_in_english(project_report.cumulative_time)}" unless @brief
        else
          $stdout.puts "  No sessions for this project."
        end

      end

  end
end