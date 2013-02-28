require 'rubygems'
require 'colorize'

module Dashline
  VERSION = '0.0.1'

  class Node
    def width(width); raise NotImplementedError; end
    def to_s; raise NotImplementedError; end
    def total_width; raise NotImplementedError; end
    def total_height; raise NotImplementedError; end

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
  end

  class Table < Node
    def initialize
      @rows = []
      @separators = []
      @aligns = []
      @width = nil
      @spacing = nil
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

    def width(width)
      @width = width
    end

    def spacing(*spacing)
      @spacing = spacing
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

    def total_height
      @rows.length + @separators.length + 2 # 2 for top/bottom borders
    end

    def total_width
      width = @width || col_widths.reduce { |a,b| a+b }
      cols = @rows.first.size
      width + (2 * cols) + (cols + 1)
    end

    private
    def col_widths
      cols = @rows.first.size # TODO: find better way to grab # of cols
      widths = [0] * cols
      (0...cols).map do |col|
        @rows.each do |row|
          widths[col] = [row[col].length, widths[col]].max
        end
      end
      pad = (2 * cols) + (cols + 1) # cell padding/borders
      sum = widths.reduce {|a,b| a+b} + pad
      if @width.nil? || sum == @width
        widths
      else
        indexes = (0...cols).to_a
        if @spacing && @spacing.uniq.length > 1
          # which columns to spread the padding within
          cols = @spacing.select { |s| s == :max }.length
          indexes = @spacing.each_index.select { |i| @spacing[i] == :max }
        end
        pad = (@width - sum) / cols
        uneven = (@width - sum) % cols
        indexes.each do |index|
          widths[index] += pad
          widths[index] += 1 if index < uneven
        end
        widths
      end
    end
  end

  class Chart < Node
    def initialize
      @title = nil
      @rows = []
    end

    def title(title)
      @title = title
    end

    def row(label, num)
      @rows << [label, num]
    end

    def to_s
      wbar, wlabel, wtitle = bar_width, label_width, title_width
      width = [wbar + wlabel + 1, wtitle].max
      separator = "+-#{'-'*width}-+"
      format = [separator]
      if @title
        format << "| #{cell(@title, width)} |"
        format << separator
      end
      @rows.each do |label, num|
        bar = '=' * num
        format << "| #{cell(label, wlabel, :right)} #{cell(bar, wbar)} |"
      end
      format << separator
      format.join("\n")
    end

    private
    def bar_width
      @rows.map { |row| row[1] }.max
    end

    def label_width
      @rows.map { |row| row[0].to_s.length }.max
    end

    def title_width
      @title.to_s.length
    end
  end

  class Grid
    def initialize
      @nodes = []
      @width = 80
    end

    def add(node)
      @nodes << node
    end

    def width(width)
      @width = width
    end

    def to_s
      buffer = []
      max_width = @nodes.map(&:total_width).max
      per_row = @width / max_width
      node_width = @width / per_row
      @nodes.each do |node|
        node = node.clone
        node.width(node_width)
        if (index = buffer.index { |l| l.length < @width })
          node.to_s.split("\n").each do |line|
            buffer[index] = " "*(buffer[index-1].length-line.length-1) if buffer[index].nil?
            buffer[index] += " #{line}"
            index += 1
          end
        else
          buffer += node.to_s.split("\n")
        end
      end
      buffer.join("\n")
    end
  end
end
