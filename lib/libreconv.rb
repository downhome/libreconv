# frozen_string_literal: true

require 'libreconv/version'
require 'uri'
require 'net/http'
require 'tmpdir'
require 'securerandom'
require 'open3'
require 'libreconv/converter'
require 'libreconv/multi_converter'

# Convert office documents using LibreOffice / OpenOffice to one of their supported formats.
module Libreconv
  class ConversionFailedError < StandardError; end

  # @param [String] source          Path or URL of the source file.
  # @param [String] target          Target file path.
  # @param [String] soffice_command Path to the soffice binary.
  # @param [String] convert_to      Format to convert to (default: 'pdf').
  # @raise [IOError]                If invalid source file/URL or soffice command not found.
  # @raise [URI::Error]             When URI parsing error.
  # @raise [Net::ProtocolError]     If source URL checking failed.
  # @raise [ConversionFailedError]  When soffice command execution error.
  class << self
    def convert(source, target, soffice_command = nil, convert_to = nil)
      Converter.new(source, target, soffice_command, convert_to).call
    end

    def convert_multiple(source_files, target_folder, soffice_command = nil, convert_to = nil)
      MultiConverter.new(source_files, target_folder, soffice_command, convert_to).call
    end
  end
end
