## args : full file path, including filename
require 'fileutils'
module Puppet::Parser::Functions
   newfunction(:create_parent_directories) do |args|
      full_file_path = args[0]
      FileUtils.mkdir_p File.dirname(full_file_path)
   end
end
