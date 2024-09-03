$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'baby-bro'
require 'baby-bro/project'
require 'yaml'
require 'openai'
require 'io/console'
require 'tty-prompt' # Ensure this line is added at the top of your file

class BabyBroConfigurator
  def initialize( config_filename = '~/.babybrorc' )
    # Initialize TTY::Prompt instance
    @prompt = TTY::Prompt.new
    @prompt.on(:keyescape) { raise Interrupt }

    # Load the configuration file
    @config_file = File.expand_path(config_filename)
    @config = YAML.load_file(@config_file) rescue default_config()
    @config[:projects].map! do |project|
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
      :data_directory => "~/.babybro",
      :polling_interval => "1 minute",
      :idle_interval => "15 minutes",
      :projects => [
      ]
    }
  end

  def save_config()
    File.write(@config_file, @config.to_yaml)
  end

  def select_project()
    @prompt.select("\nSelect a project:\n", cycle: false, per_page: 20) do |menu|
      @config[:projects].each_with_index do |project, index|
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

  def add_new_project()
    begin
      cwd = Dir.pwd
      directory_name = File.basename(Dir.pwd)
      project_name = create_project_name(directory_name)
      project_name = prompt_ask("Project name", value: project_name)
      project_directory = prompt_ask("Project directory", value: cwd)
      @config[:projects] << { name: project_name, directory: project_directory }
      save_config()
    end
  end

  def remove_project()
    begin
      @config[:projects].each_with_index { |project, index| puts "#{index + 1}. #{project[:name]}" }
      project_number = select_project()
      if project_number.between?(0, @config[:projects].size - 1)
        puts "Are you sure you want to remove #{@config[:projects][project_number][:name]}? (y/n)"
        confirmation = gets.chomp
        if confirmation.downcase == 'y'
          @config[:projects].delete_at(project_number)
          save_config()
        else
          puts "Project not removed."
        end
      else
        puts "Invalid project number."
      end
    end
  end

  def update_project()
    begin
      @config[:projects].each_with_index { |project, index| puts "#{index + 1}. #{project[:name]}" }
      project_number = select_project()
      if project_number.between?(0, @config[:projects].size - 1)
        old_project_name = @config[:projects][project_number][:name]
        new_project_name = prompt_ask("New project name", value: old_project_name)
        new_project_directory = prompt_ask("New project directory", value: @config[:projects][project_number][:directory])
        new_config = { name: new_project_name, directory: new_project_directory }
        puts "@config: #{@config}"
        if new_project_name != old_project_name
          old_config = @config[:projects][project_number]
          new_config = new_config
          hash_obj_config = HashObj.new(@config)
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
        @config[:projects][project_number] = new_config
        save_config()
      else
        puts "Invalid project number."
      end
    end
  end

  def list_projects()
    puts "\n"
    puts "@config: #{@config}"
    longest_name_length = @config[:projects].map { |project| project[:name].length }.max
    puts "  #{"PROJECT".ljust(longest_name_length)}  #{"DIRECTORY"}"
    puts
    @config[:projects].each_with_index do |project, index|
      puts "  #{project[:name].ljust(longest_name_length)}  #{project[:directory]}"
    end
    puts "\n"
  end

  def menu_options
    [
      { command: 'list', description: 'List projects' },
      { command: 'add', description: 'Add new project' },
      { command: 'remove', description: 'Remove a project' },
      { command: 'update', description: 'Update a project' },
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
    valid_choices = menu_options.map { |option| option[:command][0] }
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


  def run
    puts "\nWelcome to Baby Bro Configurator! (h for help)\n\n"
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
        when 'h'
          puts help_message()
        when 'e'
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

BabyBroConfigurator.new.run
