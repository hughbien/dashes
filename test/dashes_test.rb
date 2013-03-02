require File.expand_path('../lib/dashes', File.dirname(__FILE__))
require 'minitest/autorun'

class DashesTableTest < MiniTest::Unit::TestCase
  def test_empty
    table = Dashes::Table.new
    assert_equal('', table.to_s)
    assert_equal(0, table.total_width)
  end

  def test_cell
    table = Dashes::Table.new
    assert_equal("x", table.send(:cell, "x", 1))
    assert_equal("xx", table.send(:cell, "xxxxx", 2))
    assert_equal("x    ", table.send(:cell, "x", 5))
  end

  def test_cell_alignment
    table = Dashes::Table.new
    assert_equal("x  ", table.send(:cell, "x", 3, :left))
    assert_equal(" x ", table.send(:cell, "x", 3, :center))
    assert_equal("  x", table.send(:cell, "x", 3, :right))
  end

  def test_separators
    table = Dashes::Table.new
    table.separator
    table.separator
    table.row 'First', 'Second', 'Third'
    table.separator
    table.separator
    table.row 1, 2, 3
    table.separator
    table.separator

    assert_equal([5, 6, 5], table.send(:col_widths))
    assert_equal(26, table.total_width)
    assert_equal(
      "+-------+--------+-------+\n" +
      "+-------+--------+-------+\n" +
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "+-------+--------+-------+\n" +
      "+-------+--------+-------+\n" +
      "| 1     | 2      | 3     |\n" +
      "+-------+--------+-------+\n" +
      "+-------+--------+-------+\n" +
      "+-------+--------+-------+",
      table.to_s)
  end

  def test_alignment
    table = Dashes::Table.new
    table.align :left, :center, :right
    table.row 'First', 'Second', 'Third'
    table.separator
    table.row 1, 2, 3
    assert_equal(
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "+-------+--------+-------+\n" +
      "| 1     |    2   |     3 |\n" +
      "+-------+--------+-------+",
      table.to_s)
  end

  def test_width
    table = Dashes::Table.new
    table.width 26
    table.row '1', '2', '3'
    assert_equal(26, table.total_width)
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)

    table.spacing :min, :min, :max
    assert_equal(
      "+---+---+----------------+\n" +
      "| 1 | 2 | 3              |\n" +
      "+---+---+----------------+",
      table.to_s)

    table.spacing :max, :max, :min
    assert_equal(
      "+----------+---------+---+\n" +
      "| 1        | 2       | 3 |\n" +
      "+----------+---------+---+",
      table.to_s)

    table.spacing :min, :min, :min
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)

    table.spacing :max, :max, :max
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)
  end

  def test_max_width
    table = Dashes::Table.new
    table.max_width 26
    table.row 'First', 'Second', 'Third'
    table.row 1, 2, 3
    assert_equal(
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "| 1     | 2      | 3     |\n" +
      "+-------+--------+-------+",
      table.to_s)

    table.max_width 14
    assert_equal(
      "+---+----+---+\n" +
      "| F | Se | T |\n" +
      "| 1 | 2  | 3 |\n" +
      "+---+----+---+",
      table.to_s)

    table.width 26 # width takes priority
    assert_equal(
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "| 1     | 2      | 3     |\n" +
      "+-------+--------+-------+",
      table.to_s)
  end
end

class DashesChartTest < MiniTest::Unit::TestCase
  def test_empty
    chart = Dashes::Chart.new
    assert_equal('', chart.to_s)
    assert_equal(0, chart.total_width)
  end

  def test_basic_chart
    chart = Dashes::Chart.new
    chart.title 'Title'
    chart.row 'a', 20
    chart.row 'bb', 15
    chart.row 'ccc', 5
    chart.row 'dddd', 1

    assert_equal(
      "+---------------------------+\n" +
      "| Title                     |\n" +
      "+---------------------------+\n" +
      "|    a ==================== |\n" +
      "|   bb ===============      |\n" +
      "|  ccc =====                |\n" +
      "| dddd =                    |\n" +
      "+---------------------------+",
      chart.to_s)
  end

  def test_normalized_width
    chart = Dashes::Chart.new
    chart.width(29)
    chart.row 'a', 40
    chart.row 'bb', 30
    chart.row 'ccc', 10
    chart.row 'dddd', 2
    assert_equal(
      "+---------------------------+\n" +
      "|    a ==================== |\n" +
      "|   bb ===============      |\n" +
      "|  ccc =====                |\n" +
      "| dddd =                    |\n" +
      "+---------------------------+",
      chart.to_s)
  end

  def test_max_width
    chart = Dashes::Chart.new
    chart.max_width(100)
    chart.row 'a', 4
    chart.row 'bb', 3
    chart.row 'ccc', 2
    chart.row 'dddd', 1
    assert_equal(
      "+-----------+\n" +
      "|    a ==== |\n" +
      "|   bb ===  |\n" +
      "|  ccc ==   |\n" +
      "| dddd =    |\n" +
      "+-----------+",
      chart.to_s)

    chart2 = Dashes::Chart.new
    chart2.max_width(13)
    chart2.row 'a', 8
    chart2.row 'bb', 6
    chart2.row 'ccc', 4
    chart2.row 'dddd', 2
    assert_equal(
      "+-----------+\n" +
      "|    a ==== |\n" +
      "|   bb ===  |\n" +
      "|  ccc ==   |\n" +
      "| dddd =    |\n" +
      "+-----------+",
      chart2.to_s)

    chart2.width(17) # width should take priority
    assert_equal(
      "+---------------+\n" +
      "|    a ======== |\n" +
      "|   bb ======   |\n" +
      "|  ccc ====     |\n" +
      "| dddd ==       |\n" +
      "+---------------+",
      chart2.to_s)
  end
end

class DashesGridTest < MiniTest::Unit::TestCase
  def test_empty
    grid = Dashes::Grid.new
    assert_equal('', grid.to_s)

    grid.add Dashes::Table.new
    grid.add Dashes::Chart.new
    assert_equal('', grid.to_s)
  end

  def test_basic_grid
    table = Dashes::Table.new
    table.row 'a', 'a', 'a'
    table.separator
    table.row 'a', 'a', 'a'
    table.separator
    table.row 'a', 'a', 'a'
    table2 = Dashes::Table.new
    table2.row 'b', 'b', 'b'
    table3 = Dashes::Table.new
    table3.row 'c', 'c', 'c'

    grid = Dashes::Grid.new
    grid.width 27
    grid.add table
    grid.add table2
    grid.add table3

    assert_equal(
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | | b | b | b |\n" +
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | +---+---+---+\n" +
      "+---+---+---+ | c | c | c |\n" +
      "| a | a | a | +---+---+---+\n" +
      "+---+---+---+",
      grid.to_s)

    table4 = Dashes::Table.new
    table4.row 'a', 'a', 'a'
    table4.row 'a', 'a', 'a'
    table4.row 'a', 'a', 'a'

    grid2 = Dashes::Grid.new
    grid2.width 27
    grid2.add table4
    grid2.add table3
    grid2.add table2

    assert_equal(
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | | c | c | c |\n" +
      "| a | a | a | +---+---+---+\n" +
      "| a | a | a | +---+---+---+\n" +
      "+---+---+---+ | b | b | b |\n" +
      "              +---+---+---+",
      grid2.to_s)
  end

  def test_mixed_grid
    table = Dashes::Table.new
    table.row 'a', 'a', 'a'
    table.row 'a', 'a', 'a'
    table.row 'a', 'a', 'a'

    chart = Dashes::Chart.new
    chart.row 'a', 5
    chart.row 'bb', 3
    chart.row 'ccc', 1

    grid = Dashes::Grid.new
    grid.add table
    grid.add chart
    assert_equal(
      "+---+---+---+ +-----------+\n" +
      "| a | a | a | |   a ===== |\n" +
      "| a | a | a | |  bb ===   |\n" +
      "| a | a | a | | ccc =     |\n" +
      "+---+---+---+ +-----------+",
      grid.to_s)
  end

  def test_alternating_grid
    short = Dashes::Table.new
    short.row 'a', 'a', 'a'

    short2 = Dashes::Table.new
    short2.row 'b', 'b', 'b'

    long = Dashes::Table.new
    long.row 'd', 'd', 'd'
    long.row 'd', 'd', 'd'
    long.row 'd', 'd', 'd'

    grid = Dashes::Grid.new
    grid.width(27)
    grid.add short
    grid.add long
    grid.add short2
    assert_equal(
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | | d | d | d |\n" +
      "+---+---+---+ | d | d | d |\n" +
      "+---+---+---+ | d | d | d |\n" +
      "| b | b | b | +---+---+---+\n" +
      "+---+---+---+",
      grid.to_s)
  end
end
