require 'unit_test_helper.rb'
include ActsAsIndexed

class PreTokenizerTest < ActiveSupport::TestCase

  def test_strips_non_word_characters
    assert_equal "Chocolate Chip Cookies ", PreTokenizer.process("Chocolate-Chip Cookies!")
  end

end
