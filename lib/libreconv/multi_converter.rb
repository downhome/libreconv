module Libreconv
  class MultiConverter < Converter
    # @return [String]
    attr_accessor :soffice_command

    # @param [String] source_files   Array of paths to source file.
    # @param [String] target_folder  Target folder path.
    # @param [String] soffice_command Path to the soffice binary.
    # @param [String] convert_to      Format to convert to (default: 'pdf').
    # @raise [IOError]                If invalid source file/URL or soffice command not found.
    # @raise [URI::Error]             When URI parsing error.
    # @raise [Net::ProtocolError]     If source URL checking failed.
    def initialize(source_files, target_folder, soffice_command = nil, convert_to = nil)
      @source_files = check_source_types(source_files)
      @target_folder = target_folder
      @soffice_command = soffice_command || which('soffice') || which('soffice.bin')
      @convert_to = convert_to || 'pdf'

      ensure_soffice_exists
    end

    # @raise [ConversionFailedError]  When soffice command execution error.
    def call
      tmp_pipe_path = File.join(Dir.tmpdir, "soffice-pipe-#{SecureRandom.uuid}")

      command = build_command(tmp_pipe_path, target_folder)
      execute_command(command, target_folder)
    end

    private
    attr_reader :target_folder, :source_files

    # @param [Array<String>] command
    # @param [String] target_path
    # @return [String]
    # @raise [ConversionFailedError]  When soffice command execution error.
    def execute_command(command, target_path)
      output, error, status =
        if RUBY_PLATFORM =~ /java/
          Open3.capture3(*command)
        else
          Open3.capture3(command_env, *command, unsetenv_others: true)
        end

      return if status.success?

      raise ConversionFailedError,
        "Conversion failed! Output: #{output.strip.inspect}, Error: #{error.strip.inspect}"
    end

    # If the URL contains GET params, the '&' could break when being used as an argument to soffice.
    # Wrap it in single quotes to escape it. Then strip them from the target temp file name.
    # @return [String]
    def escaped_source
      source_files
    end

    # @param [String] source_files
    # @return [String, URI::HTTP]
    # @raise [IOError]            If invalid source file/URL.
    # @raise [URI::Error]         When URI parsing error.
    # @raise [Net::ProtocolError] If source URL checking failed.
    def check_source_types(source_files)
      source_files.map do |s|
        check_source_type(s)
      end
    end
  end
end
