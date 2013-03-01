Description
===========

Dashline formats data into a dashboard of charts/tables on the command line.

Installation
============

    $ gem install dashline

Usage
=====

Making a table:

    > table = Dashline::Table.new
    > table.align :left, :right, :right  # :center is available too
    > table.row 'Label', 'Num', 'Pct'
    > table.separator
    > table.row 'First', 1, 2
    > table.row 'Second', 3, 4
    > puts table.to_s
    +--------+-----+-----+
    | Label  | Num | Pct |
    +--------+-----+-----+
    | First  |   1 |   2 |
    | Second |   3 |   4 |
    +--------+-----+-----+

Some display options for tables:

    table.width(integer)
    table.max_width(integer) # width takes priority
    table.align(*alignments) # :left, :center, or :right
    table.spacing(*spaces)   # :min or :max, :min means never pad the cell

Making a chart:

    > chart = Dashline::Chart.new
    > chart.title 'Title'
    > chart.row 'First', 7
    > chart.row 'Second', 12
    > chart.row 'Third', 2
    > puts chart.to_s
    +---------------------+
    | Title               |
    +---------------------+
    |  First =======      |
    | Second ============ |
    |  Third ==           |
    +---------------------+

Some display options for charts:

    chart.width(integer)
    chart.max_width(integer) # width takes priority

Combine tables and charts into a grid:

    > grid = Dashline::Grid.new
    > grid.width(30) # 80 is the default , use `tput cols`.to_i for max width
    > grid.add table1
    > grid.add chart1
    > grid.add table2
    > grid.add table3
    > puts grid.to_s
    +---+---+---+ +-----------+
    | 1 | 1 | 1 | |   a ===== |
    | 1 | 1 | 1 | |  bb ===   |
    | 1 | 1 | 1 | +-----------+
    +---+---+---+ +-----------+
    | 3 | 3 | 3 | | 2 | 2 | 2 |
    +---+---+---+ +---+---+---+

Nodes (tables or charts) are added in a left-to-right, top-to-down order.
The Grid class will fill in nodes as space allows.

Development
===========

Tests are setup to run via `ruby test/*_test.rb` or via `rake`.

TODO
====

* fix uncolorize strings for lengths

License
=======

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
