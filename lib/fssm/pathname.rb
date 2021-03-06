require 'fileutils'
require 'find'
require 'pathname'

module FSSM
  class Pathname < ::Pathname
    VIRTUAL_REGEX = /^file:([^!]*)!/

    class << self
      def for(path)
        path.is_a?(::FSSM::Pathname) ? path : new(path)
      end

      alias :[] :glob
    end

    def is_virtual?
      !!(VIRTUAL_REGEX =~ to_s)
    end

    def segments
      path  = to_s
      array = []
      curdir = File.dirname("")
      while !Pathname.new(path).root? && !(path.empty? || path == curdir)
        array.unshift File.basename(path)
        path        = File.dirname(path)
      end
      suffix = path[-1] =~ Pathname::SEPARATOR_PAT ? "" : File::SEPARATOR
      array.unshift "#{path}#{suffix}" unless path.empty? || path == curdir
      array
    end

    def glob(pattern, flags = 0, &block)
      patterns = [pattern].flatten
      patterns.map! { |p| self.class.glob(to_s + p, flags, &block) }
      patterns.flatten
    end
  end
end
