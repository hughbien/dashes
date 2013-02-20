require 'rubygems'
require 'colorize'

module Dashline
  VERSION = '0.0.1'

  class Table
    def initialize
      @rows = []
      @separators = []
      @aligns = []
    end

    def row(*data)
      @rows << data.map(&:to_s)
    end

    def separator
      @separators << @rows.length
    end

    def align(*alignments)
      @aligns = alignments
    end

    def to_s
      widths = col_widths
      format = []
      separator = "+-#{widths.map {|w| '-'*w}.join('-+-')}-+"
      format << separator
      @rows.each_with_index do |row, index|
        @separators.select { |s| s == index }.count.times { format << separator }
        line = []
        row.each_with_index do |data, col|
          line << cell(data, widths[col], @aligns[col] || :left)
        end
        format << "| #{line.join(' | ')} |"
      end
      @separators.select { |s| s == @rows.length }.count.times { format << separator }
      format << separator
      format.join("\n")
    end

    private

    def cell(data, width, align=:left)
      str = data.to_s
      if str.length > width
        str[0...width]
      elsif align == :center
        lpad = " " * ((width - str.length) / 2)
        rpad = lpad.clone
        lpad += " " if (width - str.length).odd?
        lpad + str + rpad
      else
        pad = " " * (width - str.length)
        align == :left ?
          "#{str}#{pad}" :
          "#{pad}#{str}"
      end
    end

    def col_widths
      cols = @rows.first.size # TODO: find better way to grab # of cols
      widths = [0] * cols
      (0...cols).map do |col|
        @rows.each do |row|
          widths[col] = [row[col].length, widths[col]].max
        end
      end
      widths
    end
  end
end
