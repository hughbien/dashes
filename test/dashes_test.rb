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
    table = Dashes::Table.new.
      separator.
      separator.
      row('First', 'Second', 'Third').
      separator.
      separator.
      row(1, 2, 3).
      separator.
      separator

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
    table = Dashes::Table.new.
      align(:left, :center, :right).
      row('First', 'Second', 'Third').
      separator.
      row(1, 2, 3)
    assert_equal(
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "+-------+--------+-------+\n" +
      "| 1     |    2   |     3 |\n" +
      "+-------+--------+-------+",
      table.to_s)
  end

  def test_width
    table = Dashes::Table.new.
      width(26).
      row('1', '2', '3')
    assert_equal(26, table.total_width)
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)

    table.spacing(:min, :min, :max)
    assert_equal(
      "+---+---+----------------+\n" +
      "| 1 | 2 | 3              |\n" +
      "+---+---+----------------+",
      table.to_s)

    table.spacing(:max, :max, :min)
    assert_equal(
      "+----------+---------+---+\n" +
      "| 1        | 2       | 3 |\n" +
      "+----------+---------+---+",
      table.to_s)

    table.spacing(:min, :min, :min)
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)

    table.spacing(:max, :max, :max)
    assert_equal(
      "+--------+-------+-------+\n" +
      "| 1      | 2     | 3     |\n" +
      "+--------+-------+-------+",
      table.to_s)
  end

  def test_max_width
    table = Dashes::Table.new.
      max_width(26).
      row('First', 'Second', 'Third').
      row(1, 2, 3)
    assert_equal(
      "+-------+--------+-------+\n" +
      "| First | Second | Third |\n" +
      "| 1     | 2      | 3     |\n" +
      "+-------+--------+-------+",
      table.to_s)

    table.max_width(14)
    assert_equal(
      "+---+----+---+\n" +
      "| F | Se | T |\n" +
      "| 1 | 2  | 3 |\n" +
      "+---+----+---+",
      table.to_s)

    table.width(26) # width takes priority
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
    chart = Dashes::Chart.new.
      title('Title').
      row('a', 20).
      row('bb', 15).
      row('ccc', 5).
      row('dddd', 1)

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
    chart = Dashes::Chart.new.
      width(29).
      row('a', 40).
      row('bb', 30).
      row('ccc', 10).
      row('dddd', 2)
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
    chart = Dashes::Chart.new.
      max_width(100).
      row('a', 4).
      row('bb', 3).
      row('ccc', 2).
      row('dddd', 1)
    assert_equal(
      "+-----------+\n" +
      "|    a ==== |\n" +
      "|   bb ===  |\n" +
      "|  ccc ==   |\n" +
      "| dddd =    |\n" +
      "+-----------+",
      chart.to_s)

    chart2 = Dashes::Chart.new.
      max_width(13).
      row('a', 8).
      row('bb', 6).
      row('ccc', 4).
      row('dddd', 2)
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

    grid.add(Dashes::Table.new, Dashes::Chart.new)
    assert_equal('', grid.to_s)
  end

  def test_basic_grid
    table = Dashes::Table.new.
      row('a', 'a', 'a').separator.
      row('a', 'a', 'a').separator.
      row('a', 'a', 'a')
    table2 = Dashes::Table.new.row('b', 'b', 'b')
    table3 = Dashes::Table.new.row('c', 'c', 'c')

    grid = Dashes::Grid.new.width(27).add(table, table2, table3)
    assert_equal(
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | | b | b | b |\n" +
      "+---+---+---+ +---+---+---+\n" +
      "| a | a | a | +---+---+---+\n" +
      "+---+---+---+ | c | c | c |\n" +
      "| a | a | a | +---+---+---+\n" +
      "+---+---+---+",
      grid.to_s)

    table4 = Dashes::Table.new.
      row('a', 'a', 'a').
      row('a', 'a', 'a').
      row('a', 'a', 'a')

    grid2 = Dashes::Grid.new.width(27).add(table4, table3, table2)
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
    table = Dashes::Table.new.
      row('a', 'a', 'a').
      row('a', 'a', 'a').
      row('a', 'a', 'a')

    chart = Dashes::Chart.new.
      row('a', 5).
      row('bb', 3).
      row('ccc', 1)

    grid = Dashes::Grid.new.add(table, chart)
    assert_equal(
      "+---+---+---+ +-----------+\n" +
      "| a | a | a | |   a ===== |\n" +
      "| a | a | a | |  bb ===   |\n" +
      "| a | a | a | | ccc =     |\n" +
      "+---+---+---+ +-----------+",
      grid.to_s)
  end

  def test_alternating_grid
    short = Dashes::Table.new.row('a', 'a', 'a')

    short2 = Dashes::Table.new.row('b', 'b', 'b')

    long = Dashes::Table.new.
      row('d', 'd', 'd').
      row('d', 'd', 'd').
      row('d', 'd', 'd')

    grid = Dashes::Grid.new.width(27).add(short, long, short2)
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
