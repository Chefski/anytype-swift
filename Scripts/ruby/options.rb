require 'optparse'

class Options
  def self.parsed(args)
    default_options.merge options_from_args(args)
  end

  private_class_method def self.options_from_args(args)
    options = {}

    OptionParser.new do |opts|
      opts.on('-h', '--help', 'Show help') { help_message(opts); exit(0) }
      opts.on('-l', '--latest', 'Update to the latest version') {|v| options[:latest] = true }

      opts.on('--token', '--token [TOKEN]', 'Token to access repository') {|v| options[:token] = v}
      opts.on('--on-ci', 'Run on CI') { |v| options[:runsOnCI] = true }

    end.parse!(args)

    return options
  end

  private_class_method def self.default_options
    {
      latest: false,
      runsOnCI: false,
      token: ENV['ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN'] || '',
    }
  end

  private_class_method def self.help_message(options)
    puts <<-__HELP__

    #{options.help}

    You can store token in environments ~/.zshrc
    key: ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN

    __HELP__
  end

end