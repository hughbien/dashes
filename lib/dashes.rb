require 'rubygems'

module Dashes
  VERSION = '0.0.2'

  class Node
    def width(width); raise NotImplementedError; end
    def max_width(max_width); raise NotImplementedError; end
    def to_s; raise NotImplementedError; end
    def total_width; raise NotImplementedError; end

    private
    def cell(data, width, align=:left)
      str = data.to_s
      length = str.length
      if length > width
        str[0...width]
      elsif align == :center
        lpad = " " * ((width - length) / 2)
        rpad = lpad.clone
        lpad += " " if (width - length).odd?
        lpad + str + rpad
      else
        pad = " " * (width - length)
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
      @max_width = nil
      @spacing = nil
    end

    def row(*data)
      @rows << data.map(&:to_s)
      self
    end

    def separator
      @separators << @rows.length
      self
    end

    def align(*alignments)
      @aligns = alignments
      self
    end

    def width(width)
      @width = width
      self
    end

    def max_width(max_width)
      @max_width = max_width
      self
    end

    def spacing(*spacing)
      @spacing = spacing
      self
    end

    def to_s
      return '' if @rows.empty?
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

    def total_width
      if @rows.empty?
        0
      elsif @width
        @width
      else
        width = col_widths.reduce { |a,b| a+b }
        cols = @rows.first.size
        twidth = width + (2 * cols) + (cols + 1)
        @max_width ? [twidth, @max_width].min : twidth
      end
    end

    private
    def col_widths
      return [] if @rows.empty?
      cols = @rows.first.size
      widths = [0] * cols
      (0...cols).map do |col|
        @rows.each do |row|
          widths[col] = [row[col].length, widths[col]].max
        end
      end
      pad = (2 * cols) + (cols + 1) # cell padding/borders
      sum = widths.reduce {|a,b| a+b} + pad
      if sum == @width || (@width.nil? && (@max_width.nil? || sum <= @max_width))
        widths
      else
        indexes = (0...cols).to_a
        if @spacing && @spacing.uniq.length > 1
          # which columns to spread the padding within
          cols = @spacing.select { |s| s == :max }.length
          indexes = @spacing.each_index.select { |i| @spacing[i] == :max }
        end
        twidth = @width || (@max_width ? [sum, @max_width].min : sum)
        delta = twidth >= sum ? 1 : -1
        pad = ((twidth - sum).abs / cols) * delta
        uneven = (twidth - sum).abs % cols
        indexes.each do |index|
          widths[index] += pad
          widths[index] += delta if index < uneven
          widths[index] = 0 if widths[index] < 0
        end
        widths
      end
    end
  end

  class Chart < Node
    def initialize
      @title = nil
      @rows = []
      @width = nil
      @max_width = nil
    end

    def title(title)
      @title = title
      self
    end

    def row(label, num)
      @rows << [label, num]
      self
    end

    def width(width)
      @width = width
      self
    end

    def max_width(max_width)
      @max_width = max_width
      self
    end

    def to_s
      return '' if @rows.empty?
      wbar, wlabel = bar_width, label_width
      wtotal = total_width - 4 # 4 for side borders and padding
      bar_space = wtotal - wlabel - 1
      bar_ratio = wbar > bar_space ? bar_space/wbar.to_f : 1

      separator = "+-#{'-'*wtotal}-+"
      format = [separator]
      if @title
        format << "| #{cell(@title, wtotal)} |"
        format << separator
      end
      @rows.each do |label, num|
        bar = '=' * (num * bar_ratio).floor
        format << "| #{cell(label, wlabel, :right)} #{cell(bar, bar_space)} |"
      end
      format << separator
      format.join("\n")
    end

    def total_width
      if @rows.empty?
        0
      elsif @width
        @width
      else
        # 4 for borders/padding
        twidth = [bar_width + label_width + 1, title_width].max + 4
        @max_width ? [twidth, @max_width].min : twidth
      end
    end

    private
    def bar_width
      @rows.map { |row| row[1] }.max
    end

    def label_width
      @rows.map { |row| row[0].length }.max
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

    def add(*nodes)
      @nodes += nodes
      self
    end

    def width(width)
      @width = width
      self
    end

    def to_s
      return '' if @nodes.empty?
      buffer = []
      node_width = [@nodes.map(&:total_width).max, @width].min
      space_matcher = " "*(node_width+1) # 1 for padding
      @nodes.each do |node|
        node = node.clone
        node.width(node_width)
        if (index = buffer.index { |l| l.include?(space_matcher) }) 
          # there's space for the table in a row, fit it in
          col = buffer[index] =~ Regexp.new(space_matcher)
          node.to_s.split("\n").each do |line|
            if buffer[index].nil?
              buffer[index] = "#{" "*@width}"
            end
            new_line = col == 0 ?  "#{line} " : " #{line}"
            buffer[index][col..(col+node_width)] = new_line
            index += 1
          end
        else
          # there's no more room, just add the table below
          rpad = " "*(@width - node_width)
          buffer += node.to_s.split("\n").map { |line| "#{line}#{rpad}" }
        end
      end
      buffer.map(&:rstrip).join("\n")
    end
  end
end
