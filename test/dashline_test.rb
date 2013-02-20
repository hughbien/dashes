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
end
