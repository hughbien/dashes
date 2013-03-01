require File.expand_path('../lib/dashline', File.dirname(__FILE__))
require 'minitest/autorun'

class DashlineTableTest < MiniTest::Unit::TestCase
  def test_cell
    table = Dashline::Table.new
    assert_equal("x", table.send(:cell, "x", 1))
    assert_equal("xx", table.send(:cell, "xxxxx", 2))
    assert_equal("x    ", table.send(:cell, "x", 5))
  end

  def test_cell_alignment
    table = Dashline::Table.new
    assert_equal("x  ", table.send(:cell, "x", 3, :left))
    assert_equal(" x ", table.send(:cell, "x", 3, :center))
    assert_equal("  x", table.send(:cell, "x", 3, :right))
  end

  def test_separators
    table = Dashline::Table.new
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
    table = Dashline::Table.new
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
    table = Dashline::Table.new
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
    table = Dashline::Table.new
    table.max_width 27
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
  end
end

class DashlineChartTest < MiniTest::Unit::TestCase
  def test_basic_chart
    chart = Dashline::Chart.new
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
    chart = Dashline::Chart.new
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
    chart = Dashline::Chart.new
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

    chart2 = Dashline::Chart.new
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
  end
end

class DashlineGridTest < MiniTest::Unit::TestCase
  def test_basic_grid
    table = Dashline::Table.new
    table.row 'a', 'a', 'a'
    table.separator
    table.row 'a', 'a', 'a'
    table.separator
    table.row 'a', 'a', 'a'
    table2 = Dashline::Table.new
    table2.row 'b', 'b', 'b'
    table3 = Dashline::Table.new
    table3.row 'c', 'c', 'c'

    grid = Dashline::Grid.new
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

    table4 = Dashline::Table.new
    table4.row 'a', 'a', 'a'
    table4.row 'a', 'a', 'a'
    table4.row 'a', 'a', 'a'

    grid2 = Dashline::Grid.new
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
    table = Dashline::Table.new
    table.row 'a', 'a', 'a'
    table.row 'a', 'a', 'a'
    table.row 'a', 'a', 'a'

    chart = Dashline::Chart.new
    chart.row 'a', 5
    chart.row 'bb', 3
    chart.row 'ccc', 1

    grid = Dashline::Grid.new
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
    short = Dashline::Table.new
    short.row 'a', 'a', 'a'

    short2 = Dashline::Table.new
    short2.row 'b', 'b', 'b'

    long = Dashline::Table.new
    long.row 'd', 'd', 'd'
    long.row 'd', 'd', 'd'
    long.row 'd', 'd', 'd'

    grid = Dashline::Grid.new
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
