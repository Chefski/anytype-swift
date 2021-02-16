# This script generate convenient interfaces and services for protobuf models.
# Steps.
# 1. Generate interfaces.
# 2. Generate services.

# Parameters
# 1. what to generate ( or all )
# 2. which files to generate ( or all )
# 3. which tool to choose ( or default tool )
# 4. where to generate files
# 5. where look for swift-format config.

require 'optparse'
require 'shellwords'
require 'pathname'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'

module AnytypeSwiftCodegen
  class TravelerWorker < Workers::TravelerWorker
  end
  class BaseWorker < Workers::BasicWorker
    class << self
      def repository_based_tool
        "swift run anytype-swift-codegen"
      end
    end
    attr_accessor :toolPath
    def initialize(toolPath = nil)
      self.toolPath = toolPath || self.class.repository_based_tool
    end
    def is_directory?
      is_valid? && Dir.exists?(toolPath)
    end
    def is_valid?
      File.exists? toolPath
    end
    def tool
      "#{toolPath}"
    end
  end
  class BuilderWorker < BaseWorker
    def tool
      "swift"
    end
    def action
      "#{tool} build"
    end
  end
  class VersionWorker < BaseWorker
    def action
      "#{tool} version"
    end
  end
  class ListTransformsWorker < BaseWorker
    def action
      "#{tool} generate -l"
    end
  end
  class HelpWorker < BaseWorker
    def action
      "#{tool} help"
    end
  end
  class ApplyTransformsWorker < BaseWorker
    attr_accessor :options
    def initialize(toolPath, options)
      super(toolPath)
      self.options = options
    end
    def action
      result = []
      options.each {|k, v|
        result += ["--" + k.to_s, v]
      }
      "#{tool} generate #{result.join(" ")}"
    end
  end
  class FormatWorker < BaseWorker
    class << self
      def repository_based_tool
        "swift run swift-format"
      end
    end
    attr_accessor :configuration_path, :input_path
    def initialize(tool_path, configuration_path, input_path)
      super(tool_path)
      self.configuration_path = configuration_path
      self.input_path = input_path
    end
    def action
      "#{tool} -i --configuration #{configuration_path} #{input_path}"
    end
  end
end

class Pipeline
  class << self
    def say(messages)
      Voice.say messages
    end
    def start(options)
      say "Hi there! Do you want to run some codegen?"

      say "Lets' try!"

      say "First, we must travel to tool directory."

      say "You have options: #{options}"

      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
      end

      if options[:list_transforms]
        say "Look at available trasnforms!"
        puts AnytypeSwiftCodegen::ListTransformsWorker.new(options[:toolPath]).work
        finalize
        return
      end

      if options[:version]
        say "Look at current version!"
        puts AnytypeSwiftCodegen::VersionWorker.new(options[:toolPath]).work
        finalize
        return
      end

      if options[:toolHelp]
        say "Look at help meesage from tool!"
        puts AnytypeSwiftCodegen::HelpWorker.new(options[:toolPath]).work
        finalize
        return
      end

      # now, extract all required options.
      # we need only these.
      extracted_options_keys = [:filePath, :transform, :outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath, :serviceFilePath]

      sliced_options = {}
      extracted_options_keys.each {|k|
        value = options[k]
        unless value.nil?
          sliced_options[k] = value
        end
      }

      say "You want to generate something?"
      puts "sliced_options are: #{sliced_options}"
      say "Lets go!"

      AnytypeSwiftCodegen::ApplyTransformsWorker.new(options[:toolPath], sliced_options).work
      AnytypeSwiftCodegen::FormatWorker.new(options[:formatToolPath], options[:formatConfigFilePath], options[:outputFilePath]).work
      say "Congratulations! You have just generated new protobuf files!"
      finalize
    end

    def finalize
      puts "Goodbye!"
    end
  end
end

class Runner
  def self.run
    Configuration.make_all.each {|v|
      MainWork.work(v.generate)
    }
  end
  class Configuration
    class << self
      def protobuf_directory
        "#{__dir__}/../Modules/ProtobufMessages/Sources/"
      end
      def dependencies_tool_directory
        "#{__dir__}/../Dependencies/AnytypeSwiftCodegen"
      end
      def tools_directory
        "#{__dir__}/../Tools/"
      end
      def templates_directory
        "#{__dir__}/../Templates/Middleware/"
      end
      def format_configuration_file_path
        self.tools_directory + "swift-format-configuration.json"
      end
      def tool_path
        self.tools_directory + "anytype-swift-codegen"
      end
      def format_tool_path
        self.tools_directory + "swift-format"
      end
      def comments_header
        "commands+HeaderComments.pb.swift"
      end
      def service_file_path
        "#{__dir__}/../Dependencies/Middleware/protobuf/protos/service.proto"
      end
      def commands
        "commands.pb.swift"
      end
      def models
        "models.pb.swift"
      end
      def events
        "events.pb.swift"
      end
    end

    attr_accessor :kind, :filePath, :toolPath, :formatToolPath, :formatConfigFilePath
    def initialize(kind, filePath, toolPath = nil, formatToolPath = nil, formatConfigFilePath = nil)
      self.kind = kind
      self.filePath = filePath
      self.toolPath = toolPath || self.class.tool_path
      self.formatToolPath = formatToolPath || self.class.format_tool_path
      self.formatConfigFilePath = formatConfigFilePath || self.class.format_configuration_file_path
    end
    def commentsHeaderFilePath
      self.class.templates_directory + self.class.comments_header
    end
    def templatesDirectoryPath
      self.class.templates_directory
    end
    def serviceFilePath
      self.class.service_file_path
    end
    def generate
      [
        "generate", kind,
        "--toolPath", toolPath,
        "--formatToolPath", formatToolPath,
        "--filePath", filePath,
        "--formatConfigFilePath", formatConfigFilePath,
        "--commentsHeaderFilePath", commentsHeaderFilePath,
        "--templatesDirectoryPath", templatesDirectoryPath,
        "--serviceFilePath", serviceFilePath
      ]
    end

    class << self
      def make_all
        [make_inits_for_commands, make_inits_for_models, make_inits_for_events, make_error_protocols_for_commands, make_services_for_commands]
      end
      def make_error_protocols_for_commands
        new("error_protocol", self.protobuf_directory + self.commands)
      end
      def make_services_for_commands
        new("services", self.protobuf_directory + self.commands)
      end
      def make_inits_for_commands
        new("inits", self.protobuf_directory + self.commands)
      end
      def make_inits_for_models
        new("inits", self.protobuf_directory + self.models)
      end
      def make_inits_for_events
        new("inits", self.protobuf_directory + self.events)
      end
    end
  end
end

class MainWork
  class << self
    def work(arguments)
      the_work = new
      the_work.work(the_work.parse_options(arguments))
    end
  end

  # fixing arguments
  def fix_options(the_options)
    options = the_options
    [:toolPath, :filePath, :outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath, :serviceFilePath, :formatConfigFilePath, :formatToolPath].each {|v|
      unless options[v].nil?
        options[v] = File.expand_path(options[v])
      end
    }
    options
  end
  def required_keys
    [:toolPath]
  end
  def valid_options?(the_options)
    # true
    (required_keys - the_options.keys).empty?
  end

  def work(options = {})
    options = fix_options(options)

    if options[:inspection]
      puts "options are: #{options}"
    end

    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(0)
    end

    ShellExecutor.setup options[:dry_run]

    Pipeline.start(options)
  end

  # OutputFilePath <- f (filePath, transform)
  # CommentsHeaderFilePath <- f (filePath)
  # ImportsFilePath <- f (filePath, transform)
  # TemplateFilePath <- f(filePath, transform) # only for specific transforms.
  class DefaultOptionsGenerator
    module SwiftCodegenCLIOptions
      module GenerateOptions
        AVAILABLE_VARIANTS = [
          ErrorAdoption = 'e',
          RequestAndResponse = 'rr',
          MemberwiseInitializer = 'mwi',
          ServiceWithRequestAndResponse = 'swrr',
        ]
      end
    end
    # Our representation of swift-codegen utility options
    module CodegenCLIScopes
      AVAILABLE_VARIANTS = [
        Initializers = 'inits',
        Services = 'services',
        ErrorProtocol = 'error_protocol'
      ]
      def self.swift_codegen_option(scope)
        case scope
        when ErrorProtocol then SwiftCodegenCLIOptions::GenerateOptions::ErrorAdoption
        when Initializers then SwiftCodegenCLIOptions::GenerateOptions::MemberwiseInitializer
        when Services then SwiftCodegenCLIOptions::GenerateOptions::ServiceWithRequestAndResponse
        end
      end
    end
    class << self
      def available_commands
        ["generate"]
      end
      def available_actions
        CodegenCLIScopes::AVAILABLE_VARIANTS
      end
      def suffix(type, key)
        case type
          when CodegenCLIScopes::Initializers then
            case key
              when :outputFilePath then "+Initializers"
              when :templateFilePath then nil #"+Initializers+Template"
              when :commentsHeaderFilePath then "+CommentsHeader"
              when :importsFilePath then "+Initializers+Import"
            end
          when CodegenCLIScopes::Services then
            case key
              when :outputFilePath then "+Service"
              when :templateFilePath then "+Service+Template"
              when :commentsHeaderFilePath then "+CommentsHeader"
              when :importsFilePath then "+Service+Import"
            end
          when CodegenCLIScopes::ErrorProtocol then
            case key
              when :outputFilePath then "+ErrorAdoption"
              when :templateFilePath then nil
              when :commentsHeaderFilePath then "+CommentsHeader"
              when :importsFilePath then nil
            end
        end
      end

      def appended_suffix(type, key, inputFilePath, templatesDirectoryPath = nil)
        # take
        unless inputFilePath.nil?

          suffix = suffix(type, key)
          unless suffix.nil?
            pathname = Pathname.new(inputFilePath)
            basename = pathname.basename
            components = basename.to_s.split(".")
            the_name = components.first
            the_extname = components.drop(1).join(".")
            directoryPath = templatesDirectoryPath || pathname.dirname.to_s
            result_name = directoryPath + "/" + the_name + suffix + ".#{the_extname}"
            result_name
          end
        end
      end

      def chosen_option_key_and_transform(arguments)
        CodegenCLIScopes::AVAILABLE_VARIANTS
          .filter{|x| arguments.include?(x)}
          .map{|x| [x, CodegenCLIScopes.swift_codegen_option(x)]}
          .first
      end

      def generate(arguments, options)
        if arguments.first == 'generate'
          generate_options = chosen_option_key_and_transform arguments
          if generate_options.count == 2
            key = generate_options.first
            transform = generate_options.last
            result = {
              transform: transform,
              filePath: options[:filePath],
            }

            options[:templatesDirectoryPath] ||= Pathname.new(options[:filePath]).dirname.to_s
            options[:templatesDirectoryPath] = File.expand_path(options[:templatesDirectoryPath])
            puts "options: #{options}"
            keys = [:outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath]
            for k in keys
              directoryPath = k == :outputFilePath ? nil : options[:templatesDirectoryPath]
              value = self.appended_suffix(key, k, options[:filePath], directoryPath)
              unless value.nil?
                result[k] = value
              end
            end
            result
          end
        end
      end
      def populate(arguments, options)
        new_options = self.generate(arguments, options)
        new_options.merge(options)
      end
    end
  end

  def help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you generate pb.swift convenient interfaces and services.

    First, it takes arguments:
    [required] <--toolPath PATH> Path to a directory with tool, in our case anytype-swift-codegen directory.
    [required] <--filePath PATH> Path to a file which will be used to generate desired services and interfaces.
    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    1. No parameters.
    ruby #{$0}

    # or if you want Siri Voice, set environment variable SIRI_VOICE=1
    SIRI_VOICE=1 ruby #{$0}

    Run without parameters will active default configuration and script will generate all necessary interfaces and services from default directory.

    Default protobuf directory: #{File.expand_path(Runner::Configuration.protobuf_directory)}
    Default tool directory: #{File.expand_path(Runner::Configuration.tools_directory)}
    Default tool path: #{File.expand_path(Runner::Configuration.tool_path)}
    Default format tool path: #{File.expand_path(Runner::Configuration.format_tool_path)}
    Default format swift configuration file path: #{File.expand_path(Runner::Configuration.format_configuration_file_path)}

    2. Parameters
    ruby #{$0} generate inits --filePath <PATH> --toolPath <TOOL_PATH> [other parameters].
    But passing any parameter will trigger behavior of target code generation.

    Available commands e.g. generate: [#{DefaultOptionsGenerator.available_commands}]

    Available actions e.g. inits: [#{DefaultOptionsGenerator.available_actions}]


    __HELP__
  end

  def parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-v', '--version', 'Version of tool') {|v| options[:version] = v}

      opts.on('--format-config', '--formatConfigFilePath CONFIG', 'Path to file with configuration for swift-format') {|v| options[:formatConfigFilePath] = v}
      opts.on('--format-conifg-tool', '--formatToolPath PATH', 'Path to format tool') {|v| options[:formatToolPath] = v}
      # # tool option
      opts.on('--cli', '--toolPath PATH', 'Path to directory with anytype-swift-codegen') {|v| options[:toolPath] = v}
      opts.on('--toolHelp', '--toolHelp', 'Print tool help message') {|v| options[:toolHelp] = v}

      # # transform options
      opts.on('-l', '--list_transforms', 'List available transforms') {|v| options[:list_transforms] = v}
      opts.on('-t', '--transform TRANSFORM', 'Which transform we would like to apply') {|v| options[:transform] = v}

      # # file options
      opts.on('-f', '--filePath PATH', 'Input file with generated swift protobuf models') {|v| options[:filePath] = v}
      opts.on('--outputFilePath', '--outputFilePath PATH', 'Output to file') {|v| options[:outputFilePath] = v}
      opts.on('--templateFilePath', '--templateFilePath PATH', 'File with templates which are used in some transforms'){|v| options[:templateFilePath] = v}
      opts.on('--commentsHeaderFilePath', '--commentsHeaderFilePath PATH', 'Header at the top of file'){|v| options[:commentsHeaderFilePath] = v}
      opts.on('--importsFilePath', '--importsFilePath PATH', 'Import statements at the top of file'){|v| options[:importsFilePath] = v}
      opts.on('--templatesDirectoryPath', '--templatesDirectoryPath PATH', 'Templates directory path'){|v| options[:templatesDirectoryPath] = v}
      opts.on('--serviceFilePath', '--serviceFilePath PATH', 'Rpc service file that contains Rpc services descriptions in .proto (protobuffers) format.') {|v| options[:serviceFilePath] = v}

      opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
      opts.on('-i', '--inspection', 'Inspection of all items, like tests'){|v| options[:inspection] = v}
      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}
    end.parse!(arguments)
    DefaultOptionsGenerator.populate(arguments, options)
  end
end

if ARGV.empty?
  Runner.run
else
  MainWork.work(ARGV)
end