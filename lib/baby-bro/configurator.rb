%w(project base_config).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

require 'yaml'
require 'openai'
require 'io/console'
require 'tty-prompt'

module BabyBro
  class Configurator
    include BaseConfig

    def initialize( options )
      @base_config = HashObj.new( process_base_config( options ) )
      # Initialize TTY::Prompt instance
      @prompt = TTY::Prompt.new
      @prompt.on(:keyescape) { raise Interrupt }

      # Load the configuration file
      @raw_config = YAML.load_file(@config_file) rescue default_config()
      @raw_config[:data][:directory] = @raw_config[:data][:directory].gsub('~', ENV['HOME'])
      @raw_config[:projects].map! do |project|
        project[:directory] = project[:directory].gsub('~', ENV['HOME'])
        project
      end

      # Initialize OpenAI API client
      openai_key = ENV['OPENAI_API_KEY']
      if !(openai_key.nil? || openai_key.empty?)
        @openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      end
    end

    def default_config()
      {
        :data_directory => "#{ENV["HOME"]}/.babybro",
        :polling_interval => "1 minute",
        :idle_interval => "15 minutes",
        :projects => [
        ]
      }
    end

    def save_config()
      File.write(@config_file, @raw_config.to_yaml)
    end

    def select_project()
      @prompt.select("\nSelect a project:\n", cycle: false, per_page: 20) do |menu|
        @raw_config[:projects].each_with_index do |project, index|
          menu.choice "#{project[:name]} - #{project[:directory]}", index
        end
      end
    end

    def token_is_word(token)
      return true unless @openai_client
      response = @openai_client.chat(
        parameters: {
          model: 'gpt-4o-mini-2024-07-18', # Ensure this model is available and suitable
          messages: [
            { role: "system", content: "Your sole purpose is to indicate if a token is an english word.  You will be provided with the token.  You will respond with only the token if it is an english word, or nothing if it is not." },
            { role: "user", content: "Token: #{token}" }
          ],
          max_tokens: 50
        }
      )
      response.dig('choices', 0, 'message', 'content').gsub(/\s+/, '').downcase == token.downcase
    end

    def create_project_name(directory)
      project_name = File.basename(directory)
      project_name = project_name.gsub(/\s+/, '_').gsub(/[\_\-]+/,'_')
      parts = project_name.split('_')
      parts = parts.reject { |p| p.nil? || p.empty? }
      parts = parts.map { |p| p.upcase if !token_is_word(p); p }
      parts = parts.map { |p| p[0] = p[0].upcase if p[0].upcase != p[0]; p }
      project_name = parts.join(' ')
    end

    def prompt_ask(message, **options)
      @prompt.ask("#{message}?", **options)
    end

    def prompt_select(message, **options)
      @prompt.select("#{message}?", **options)
    end

    def add_new_project(opts={})
      auto_confirm = opts[:auto_confirm]
      begin
        cwd = Dir.pwd
        directory_name = File.basename(Dir.pwd)
        project_name = create_project_name(directory_name)
        project_name = prompt_ask("Project name", value: project_name) unless auto_confirm
        projects = @raw_config[:projects].dup
        # Check if project name is already in use
        if projects.any?{|p| p[:name] == project_name}
          puts "Project name '#{project_name}' already in use.  Aborting."
          puts "Run `bro config` to inspect." if auto_confirm
          return
        end
        project_directory = cwd
        project_directory = prompt_ask("Project directory", value: project_directory) unless auto_confirm
        # Check if project directory is already in use
        p = projects.select{|p| p[:directory] == project_directory}
        if p.any?
          puts "Project directory already being monitored by project '#{p.first[:name]}'.  Aborting."
          puts "Run `bro config` to inspect." if auto_confirm
          return
        end
        @raw_config[:projects] << { name: project_name, directory: project_directory }
        save_config()
        puts "Project '#{project_name}' added."
      end
    end

    def remove_project()
      begin
        @raw_config[:projects].each_with_index { |project, index| puts "#{index + 1}. #{project[:name]}" }
        project_number = select_project()
        if project_number.between?(0, @raw_config[:projects].size - 1)
          project_name = @raw_config[:projects][project_number][:name]
          confirmation = !@prompt.no?( "Are you sure you want to remove #{project_name}")
          if confirmation
            @raw_config[:projects].delete_at(project_number)
            save_config()
            puts "#{project_name} project was removed."
          else
            puts "#{project_name} project was NOT removed."
          end
        else
          puts "Invalid project number."
        end
      end
    end

    def update_project()
      begin
        @raw_config[:projects].each_with_index { |project, index| puts "#{index + 1}. #{project[:name]}" }
        project_number = select_project()
        if project_number.between?(0, @raw_config[:projects].size - 1)
          old_project_name = @raw_config[:projects][project_number][:name]
          new_project_name = prompt_ask("New project name", value: old_project_name)
          new_project_directory = prompt_ask("New project directory", value: @raw_config[:projects][project_number][:directory])
          new_config = { name: new_project_name, directory: new_project_directory }
          if new_project_name != old_project_name
            old_config = @raw_config[:projects][project_number]
            new_config = new_config
            hash_obj_config = HashObj.new(@raw_config)
            old_project = BabyBro::Project.new(old_config, hash_obj_config)
            new_project = BabyBro::Project.new(new_config, hash_obj_config)
            old_dir = old_project.data_dir.gsub('~', ENV['HOME'])
            new_dir = new_project.data_dir.gsub('~', ENV['HOME'])
            begin
              if File.directory?(old_dir)
                puts "The data directory must be moved:\n #{old_dir} ==> #{new_dir}"
                FileUtils.mv(old_dir, new_dir, verbose: true, force: true)
                puts "Data directory moved successfully."
              end
            rescue Errno::EACCES
              puts "Error: Permission denied. Make sure you have the necessary permissions."
            rescue Errno::ENOENT
              puts "Error: Source directory does not exist."
            rescue Errno::EEXIST
              puts "Error: Destination directory already exists."
            rescue => e
              puts "An error occurred: #{e.message}"
              puts e.backtrace
            end
          end
          @raw_config[:projects][project_number] = new_config
          save_config()
        else
          puts "Invalid project number."
        end
      end
    end

    def list_projects()
      puts "\nConfiguration:\n\n"
      print_polling_config()
      longest_name_length = @raw_config[:projects].map { |project| project[:name].length }.max
      puts "  #{"PROJECT".ljust(longest_name_length)}  #{"DIRECTORY"}"
      puts
      @base_config[:projects].each_with_index do |project, index|
        puts "  #{project[:name].ljust(longest_name_length)}  #{project[:directory]}"
      end
      puts "\n"
    end

    def polling_config()
      puts "\nPolling Configuration:\n\n"
      print_polling_config()
      polling_interval = prompt_ask("Polling interval", value: @raw_config[:monitor][:polling_interval])
      idle_interval = prompt_ask("Idle interval", value: @raw_config[:monitor][:idle_interval])
      @raw_config[:monitor][:polling_interval] = polling_interval
      @raw_config[:monitor][:idle_interval] = idle_interval
      save_config()
      puts "Polling configuration updated.\n\n"
    end

    def menu_options
      [
        { command: 'list', description: 'List configuration and projects' },
        { command: 'add', description: 'Add new project' },
        { command: 'remove', description: 'Remove a project' },
        { command: 'update', description: 'Update a project' },
        { command: 'polling', description: 'Polling configuration' },
        { command: 'help', description: 'Show this help message' },
        { command: 'exit', description: 'Exit' }
      ]
    end

    def help_message
      longest_command_length = menu_options.map { |option| option[:command].length }.max + " (x)".length
      help_message = menu_options.map { |option| "  #{"#{option[:command]} (#{option[:command][0]})".ljust(longest_command_length)} - #{option[:description]}" }.join("\n")
      help_message = "\nCommands:\n\n" + help_message + "\n\n"
      help_message
    end

    def get_menu_choice()
      valid_choices = menu_options.map { |option| option[:command][0] }.append('q') # Add 'q' for quit
      choice = ""
      while choice == ""
        choice = @prompt.ask(">>") || ""
        choice = choice.downcase[0] || ""
        next if choice == ""
        if !valid_choices.include?(choice)
          puts "#{help_message}"
          choice = ""
        end
      end
      return choice
    end

    def print_polling_config()
      polling_interval = @base_config.monitor.polling_interval
      idle_interval = @base_config.monitor.idle_interval
      puts "  Polling interval: #{polling_interval}\n"
      puts "  Idle interval: #{idle_interval}\n\n"
    end

    def run()
      if @base_config.add
        add_new_project(auto_confirm: true)
        return
      end
      puts "\nWelcome to Baby Bro Configurator!\nconfig file: #{@config_file}\n(h for help)\n\n"
      loop do
        choice = get_menu_choice()
        begin
          case choice
          when 'a'
            add_new_project()
          when 'r'
            remove_project()
          when 'u'
            update_project()
          when 'l'
            list_projects()
          when 'p'
            polling_config()
          when 'h'
            puts help_message()
          when 'e', 'q'
            break
          else
            puts "Invalid option. Please try again."
          end
        rescue Interrupt
          puts "\n\nOperation interrupted. Returning to main menu."
        end
      rescue Interrupt
        puts "\nExiting..."
        exit
      end
    end
  end
end

if __FILE__ == $0
  puts File.expand_path("~/.babybrorc")
end
