gem 'minitest', '~> 5.4'
require 'minitest/autorun'
require 'minitest/pride'
# require_relative '../lib/bottles'

class Verse
  def initialize(bottle_stock)
    @bottle_stock = bottle_stock
  end

  def stock
    beer_on_the_wall(start = true) +
      bottle_of_beer + ".\n"
  end

  def take_one_bottle
    return "Go to the store and buy some more, " if @bottle_stock.is_empty
    "Take #{pronoun} down and pass it around, "
  end

  def beer_on_the_wall(first_line = true)
    return punctuation(first_line, "#{bottle_of_beer} on the wall")
  end

  private

  def punctuation(first_line, verse)
    return verse.capitalize + ", " if first_line
    verse + ".\n"
  end

  def end_of_line(first_line = true)
    return ", " if first_line
    ".\n"
  end

  def bottle_of_beer
    "#{@bottle_stock} #{bottle} of beer"
  end

  def bottle
    return NounBottle.new(bottle_stock = @bottle_stock).to_s
  end

  def pronoun
    return Pronoun.new(bottle_stock = @bottle_stock).when_take_bottle
  end

end

class BottleStock
  attr_reader :quantity

  def initialize(quantity)
    @quantity = quantity
  end

  def decremente
    if is_empty
      return BottleStock.new(quantity = 99)
    end
    BottleStock.new(quantity = @quantity - 1)
  end

  def is_the_last_one
    return @quantity == 1
  end

  def are_there_many
    @quantity > 1
  end

  def is_empty
    @quantity == 0
  end

  def to_s
    return "no more" if is_empty
    "#{@quantity}"
  end

end

class Bottles

  def verse(number)
    stock = BottleStock.new(initial_stock = number)
    verse = Verse.new(bottle_stock = stock)
    return verse.stock + verse.take_one_bottle + Verse.new(stock.decremente).beer_on_the_wall(start = false)
  end

  def verses(upper_stock, lower_stock)
    result = []
    upper_stock.downto(lower_stock) { |num| result.append(verse(num)) }
    result.join("\n")
  end

  def song
    verses(upper_stock = 99, lower_stock = 0)
  end

end

class NounBottle
  def initialize(bottle_stock)
    @bottle_stock = bottle_stock
  end

  def to_s
    return "bottle" if @bottle_stock.is_the_last_one
    "bottles"
  end
end

class Pronoun
  def initialize(bottle_stock)
    @bottle_stock = bottle_stock
  end

  def when_take_bottle
    return "it" if @bottle_stock.is_the_last_one
    "one"
  end
end

class NounBottleTest < Minitest::Test
  def test_plural
    assert_equal "bottles", NounBottle.new(BottleStock.new(4)).to_s
  end

  def test_singular
    assert_equal "bottle", NounBottle.new(BottleStock.new(1)).to_s
  end

  def test_no_more_bottles
    assert_equal "bottles", NounBottle.new(BottleStock.new(0)).to_s
  end
end

class PronounTest < Minitest::Test
  def test_pronoun_for_take_bottle
    assert_equal "one", Pronoun.new(BottleStock.new(4)).when_take_bottle
  end

  def test_pronoun_for_take_bottle_when_is_last_one
    assert_equal "it", Pronoun.new(BottleStock.new(1)).when_take_bottle
  end
end

class BottlesTest < Minitest::Test
  def test_the_first_verse
    expected =
      "99 bottles of beer on the wall, " +
        "99 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "98 bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verse(99)
  end

  def test_another_verse
    expected =
      "3 bottles of beer on the wall, " +
        "3 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "2 bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verse(3)
  end

  def test_verse_2
    expected =
      "2 bottles of beer on the wall, " +
        "2 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "1 bottle of beer on the wall.\n"
    assert_equal expected, Bottles.new.verse(2)
  end

  def test_verse_1
    expected =
      "1 bottle of beer on the wall, " +
        "1 bottle of beer.\n" +
        "Take it down and pass it around, " +
        "no more bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verse(1)
  end

  def test_verse_0
    expected =
      "No more bottles of beer on the wall, " +
        "no more bottles of beer.\n" +
        "Go to the store and buy some more, " +
        "99 bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verse(0)
  end

  def test_a_couple_verses
    expected =
      "99 bottles of beer on the wall, " +
        "99 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "98 bottles of beer on the wall.\n" +
        "\n" +
        "98 bottles of beer on the wall, " +
        "98 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "97 bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verses(99, 98)
  end

  def test_a_few_verses
    expected =
      "2 bottles of beer on the wall, " +
        "2 bottles of beer.\n" +
        "Take one down and pass it around, " +
        "1 bottle of beer on the wall.\n" +
        "\n" +
        "1 bottle of beer on the wall, " +
        "1 bottle of beer.\n" +
        "Take it down and pass it around, " +
        "no more bottles of beer on the wall.\n" +
        "\n" +
        "No more bottles of beer on the wall, " +
        "no more bottles of beer.\n" +
        "Go to the store and buy some more, " +
        "99 bottles of beer on the wall.\n"
    assert_equal expected, Bottles.new.verses(2, 0)
  end

  def test_the_whole_song
    expected = <<~SONG
      99 bottles of beer on the wall, 99 bottles of beer.
      Take one down and pass it around, 98 bottles of beer on the wall.

      98 bottles of beer on the wall, 98 bottles of beer.
      Take one down and pass it around, 97 bottles of beer on the wall.

      97 bottles of beer on the wall, 97 bottles of beer.
      Take one down and pass it around, 96 bottles of beer on the wall.

      96 bottles of beer on the wall, 96 bottles of beer.
      Take one down and pass it around, 95 bottles of beer on the wall.

      95 bottles of beer on the wall, 95 bottles of beer.
      Take one down and pass it around, 94 bottles of beer on the wall.

      94 bottles of beer on the wall, 94 bottles of beer.
      Take one down and pass it around, 93 bottles of beer on the wall.

      93 bottles of beer on the wall, 93 bottles of beer.
      Take one down and pass it around, 92 bottles of beer on the wall.

      92 bottles of beer on the wall, 92 bottles of beer.
      Take one down and pass it around, 91 bottles of beer on the wall.

      91 bottles of beer on the wall, 91 bottles of beer.
      Take one down and pass it around, 90 bottles of beer on the wall.

      90 bottles of beer on the wall, 90 bottles of beer.
      Take one down and pass it around, 89 bottles of beer on the wall.

      89 bottles of beer on the wall, 89 bottles of beer.
      Take one down and pass it around, 88 bottles of beer on the wall.

      88 bottles of beer on the wall, 88 bottles of beer.
      Take one down and pass it around, 87 bottles of beer on the wall.

      87 bottles of beer on the wall, 87 bottles of beer.
      Take one down and pass it around, 86 bottles of beer on the wall.

      86 bottles of beer on the wall, 86 bottles of beer.
      Take one down and pass it around, 85 bottles of beer on the wall.

      85 bottles of beer on the wall, 85 bottles of beer.
      Take one down and pass it around, 84 bottles of beer on the wall.

      84 bottles of beer on the wall, 84 bottles of beer.
      Take one down and pass it around, 83 bottles of beer on the wall.

      83 bottles of beer on the wall, 83 bottles of beer.
      Take one down and pass it around, 82 bottles of beer on the wall.

      82 bottles of beer on the wall, 82 bottles of beer.
      Take one down and pass it around, 81 bottles of beer on the wall.

      81 bottles of beer on the wall, 81 bottles of beer.
      Take one down and pass it around, 80 bottles of beer on the wall.

      80 bottles of beer on the wall, 80 bottles of beer.
      Take one down and pass it around, 79 bottles of beer on the wall.

      79 bottles of beer on the wall, 79 bottles of beer.
      Take one down and pass it around, 78 bottles of beer on the wall.

      78 bottles of beer on the wall, 78 bottles of beer.
      Take one down and pass it around, 77 bottles of beer on the wall.

      77 bottles of beer on the wall, 77 bottles of beer.
      Take one down and pass it around, 76 bottles of beer on the wall.

      76 bottles of beer on the wall, 76 bottles of beer.
      Take one down and pass it around, 75 bottles of beer on the wall.

      75 bottles of beer on the wall, 75 bottles of beer.
      Take one down and pass it around, 74 bottles of beer on the wall.

      74 bottles of beer on the wall, 74 bottles of beer.
      Take one down and pass it around, 73 bottles of beer on the wall.

      73 bottles of beer on the wall, 73 bottles of beer.
      Take one down and pass it around, 72 bottles of beer on the wall.

      72 bottles of beer on the wall, 72 bottles of beer.
      Take one down and pass it around, 71 bottles of beer on the wall.

      71 bottles of beer on the wall, 71 bottles of beer.
      Take one down and pass it around, 70 bottles of beer on the wall.

      70 bottles of beer on the wall, 70 bottles of beer.
      Take one down and pass it around, 69 bottles of beer on the wall.

      69 bottles of beer on the wall, 69 bottles of beer.
      Take one down and pass it around, 68 bottles of beer on the wall.

      68 bottles of beer on the wall, 68 bottles of beer.
      Take one down and pass it around, 67 bottles of beer on the wall.

      67 bottles of beer on the wall, 67 bottles of beer.
      Take one down and pass it around, 66 bottles of beer on the wall.

      66 bottles of beer on the wall, 66 bottles of beer.
      Take one down and pass it around, 65 bottles of beer on the wall.

      65 bottles of beer on the wall, 65 bottles of beer.
      Take one down and pass it around, 64 bottles of beer on the wall.

      64 bottles of beer on the wall, 64 bottles of beer.
      Take one down and pass it around, 63 bottles of beer on the wall.

      63 bottles of beer on the wall, 63 bottles of beer.
      Take one down and pass it around, 62 bottles of beer on the wall.

      62 bottles of beer on the wall, 62 bottles of beer.
      Take one down and pass it around, 61 bottles of beer on the wall.

      61 bottles of beer on the wall, 61 bottles of beer.
      Take one down and pass it around, 60 bottles of beer on the wall.

      60 bottles of beer on the wall, 60 bottles of beer.
      Take one down and pass it around, 59 bottles of beer on the wall.

      59 bottles of beer on the wall, 59 bottles of beer.
      Take one down and pass it around, 58 bottles of beer on the wall.

      58 bottles of beer on the wall, 58 bottles of beer.
      Take one down and pass it around, 57 bottles of beer on the wall.

      57 bottles of beer on the wall, 57 bottles of beer.
      Take one down and pass it around, 56 bottles of beer on the wall.

      56 bottles of beer on the wall, 56 bottles of beer.
      Take one down and pass it around, 55 bottles of beer on the wall.

      55 bottles of beer on the wall, 55 bottles of beer.
      Take one down and pass it around, 54 bottles of beer on the wall.

      54 bottles of beer on the wall, 54 bottles of beer.
      Take one down and pass it around, 53 bottles of beer on the wall.

      53 bottles of beer on the wall, 53 bottles of beer.
      Take one down and pass it around, 52 bottles of beer on the wall.

      52 bottles of beer on the wall, 52 bottles of beer.
      Take one down and pass it around, 51 bottles of beer on the wall.

      51 bottles of beer on the wall, 51 bottles of beer.
      Take one down and pass it around, 50 bottles of beer on the wall.

      50 bottles of beer on the wall, 50 bottles of beer.
      Take one down and pass it around, 49 bottles of beer on the wall.

      49 bottles of beer on the wall, 49 bottles of beer.
      Take one down and pass it around, 48 bottles of beer on the wall.

      48 bottles of beer on the wall, 48 bottles of beer.
      Take one down and pass it around, 47 bottles of beer on the wall.

      47 bottles of beer on the wall, 47 bottles of beer.
      Take one down and pass it around, 46 bottles of beer on the wall.

      46 bottles of beer on the wall, 46 bottles of beer.
      Take one down and pass it around, 45 bottles of beer on the wall.

      45 bottles of beer on the wall, 45 bottles of beer.
      Take one down and pass it around, 44 bottles of beer on the wall.

      44 bottles of beer on the wall, 44 bottles of beer.
      Take one down and pass it around, 43 bottles of beer on the wall.

      43 bottles of beer on the wall, 43 bottles of beer.
      Take one down and pass it around, 42 bottles of beer on the wall.

      42 bottles of beer on the wall, 42 bottles of beer.
      Take one down and pass it around, 41 bottles of beer on the wall.

      41 bottles of beer on the wall, 41 bottles of beer.
      Take one down and pass it around, 40 bottles of beer on the wall.

      40 bottles of beer on the wall, 40 bottles of beer.
      Take one down and pass it around, 39 bottles of beer on the wall.

      39 bottles of beer on the wall, 39 bottles of beer.
      Take one down and pass it around, 38 bottles of beer on the wall.

      38 bottles of beer on the wall, 38 bottles of beer.
      Take one down and pass it around, 37 bottles of beer on the wall.

      37 bottles of beer on the wall, 37 bottles of beer.
      Take one down and pass it around, 36 bottles of beer on the wall.

      36 bottles of beer on the wall, 36 bottles of beer.
      Take one down and pass it around, 35 bottles of beer on the wall.

      35 bottles of beer on the wall, 35 bottles of beer.
      Take one down and pass it around, 34 bottles of beer on the wall.

      34 bottles of beer on the wall, 34 bottles of beer.
      Take one down and pass it around, 33 bottles of beer on the wall.

      33 bottles of beer on the wall, 33 bottles of beer.
      Take one down and pass it around, 32 bottles of beer on the wall.

      32 bottles of beer on the wall, 32 bottles of beer.
      Take one down and pass it around, 31 bottles of beer on the wall.

      31 bottles of beer on the wall, 31 bottles of beer.
      Take one down and pass it around, 30 bottles of beer on the wall.

      30 bottles of beer on the wall, 30 bottles of beer.
      Take one down and pass it around, 29 bottles of beer on the wall.

      29 bottles of beer on the wall, 29 bottles of beer.
      Take one down and pass it around, 28 bottles of beer on the wall.

      28 bottles of beer on the wall, 28 bottles of beer.
      Take one down and pass it around, 27 bottles of beer on the wall.

      27 bottles of beer on the wall, 27 bottles of beer.
      Take one down and pass it around, 26 bottles of beer on the wall.

      26 bottles of beer on the wall, 26 bottles of beer.
      Take one down and pass it around, 25 bottles of beer on the wall.

      25 bottles of beer on the wall, 25 bottles of beer.
      Take one down and pass it around, 24 bottles of beer on the wall.

      24 bottles of beer on the wall, 24 bottles of beer.
      Take one down and pass it around, 23 bottles of beer on the wall.

      23 bottles of beer on the wall, 23 bottles of beer.
      Take one down and pass it around, 22 bottles of beer on the wall.

      22 bottles of beer on the wall, 22 bottles of beer.
      Take one down and pass it around, 21 bottles of beer on the wall.

      21 bottles of beer on the wall, 21 bottles of beer.
      Take one down and pass it around, 20 bottles of beer on the wall.

      20 bottles of beer on the wall, 20 bottles of beer.
      Take one down and pass it around, 19 bottles of beer on the wall.

      19 bottles of beer on the wall, 19 bottles of beer.
      Take one down and pass it around, 18 bottles of beer on the wall.

      18 bottles of beer on the wall, 18 bottles of beer.
      Take one down and pass it around, 17 bottles of beer on the wall.

      17 bottles of beer on the wall, 17 bottles of beer.
      Take one down and pass it around, 16 bottles of beer on the wall.

      16 bottles of beer on the wall, 16 bottles of beer.
      Take one down and pass it around, 15 bottles of beer on the wall.

      15 bottles of beer on the wall, 15 bottles of beer.
      Take one down and pass it around, 14 bottles of beer on the wall.

      14 bottles of beer on the wall, 14 bottles of beer.
      Take one down and pass it around, 13 bottles of beer on the wall.

      13 bottles of beer on the wall, 13 bottles of beer.
      Take one down and pass it around, 12 bottles of beer on the wall.

      12 bottles of beer on the wall, 12 bottles of beer.
      Take one down and pass it around, 11 bottles of beer on the wall.

      11 bottles of beer on the wall, 11 bottles of beer.
      Take one down and pass it around, 10 bottles of beer on the wall.

      10 bottles of beer on the wall, 10 bottles of beer.
      Take one down and pass it around, 9 bottles of beer on the wall.

      9 bottles of beer on the wall, 9 bottles of beer.
      Take one down and pass it around, 8 bottles of beer on the wall.

      8 bottles of beer on the wall, 8 bottles of beer.
      Take one down and pass it around, 7 bottles of beer on the wall.

      7 bottles of beer on the wall, 7 bottles of beer.
      Take one down and pass it around, 6 bottles of beer on the wall.

      6 bottles of beer on the wall, 6 bottles of beer.
      Take one down and pass it around, 5 bottles of beer on the wall.

      5 bottles of beer on the wall, 5 bottles of beer.
      Take one down and pass it around, 4 bottles of beer on the wall.

      4 bottles of beer on the wall, 4 bottles of beer.
      Take one down and pass it around, 3 bottles of beer on the wall.

      3 bottles of beer on the wall, 3 bottles of beer.
      Take one down and pass it around, 2 bottles of beer on the wall.

      2 bottles of beer on the wall, 2 bottles of beer.
      Take one down and pass it around, 1 bottle of beer on the wall.

      1 bottle of beer on the wall, 1 bottle of beer.
      Take it down and pass it around, no more bottles of beer on the wall.

      No more bottles of beer on the wall, no more bottles of beer.
      Go to the store and buy some more, 99 bottles of beer on the wall.
    SONG
    assert_equal expected, Bottles.new.song
  end
end