require File.dirname(__FILE__) + '/abstract_unit'
include Foo::Acts::Indexed

class SearchAtomTest < ActiveSupport::TestCase  
  
  def test_should_create_a_new_instance
    assert SearchAtom.new
  end
  
  def test_include_record_should_return_false
    assert ! SearchAtom.new.include_record?(123)
  end
  
  def test_include_record_should_return_true
    assert build_search_atom.include_record?(123)
  end
  
  def test_add_record_should_add_record
    search_atom = SearchAtom.new
    search_atom.add_record(456)
    
    assert search_atom.include_record?(456)
  end
  
  def test_add_record_should_leave_positions_untouched
    search_atom = build_search_atom
    original_records_count = search_atom.record_ids.size
    
    search_atom.add_record(123)
    assert_equal original_records_count, search_atom.record_ids.size
    assert_equal [2,23,78], search_atom.positions(123)
  end
  
  def test_add_position_should_add_position
    search_atom = build_search_atom
    search_atom.expects(:add_record).with(123)
    
    search_atom.add_position(123,98)
    assert search_atom.positions(123).include?(98)
  end
  
  def test_record_ids_should_return_obvious
    assert_equal [123], build_search_atom.record_ids
  end
  
  def test_positions_should_return_positions
    assert_equal [2,23,78], build_search_atom.positions(123)
  end
  
  def test_positions_should_return_nil
    assert_equal nil, build_search_atom.positions(456)
  end
  
  def test_remove_record
    search_atom = build_search_atom
    search_atom.remove_record(123)
    assert ! search_atom.include_record?(123)
  end
  
  def test_preceded_by
    former = build_search_atom({ 1 => [1], 2 => [1] })
    latter = build_search_atom({ 1 => [2], 2 => [3] })
    result = latter.preceded_by(former)
    assert_equal [1], result.record_ids
    assert_equal [2], result.positions(1)
  end
  
  def test_weightings
    # 5 documents.
    weightings = build_search_atom({ 1 => [1, 8], 2 => [1] }).weightings(5)
    assert_in_delta(1.38629436111989, weightings[1], 2 ** -20)
    assert_in_delta(0.693147180559945, weightings[2], 2 ** -20)
    
    # Empty positions.
    weightings = build_search_atom({ 1 => [1, 8], 2 => [] }).weightings(5)
    assert_in_delta(1.38629436111989, weightings[1], 2 ** -20)
    assert_in_delta(0.0, weightings[2], 2 ** -20)
    
    # 10 documents.
    weightings = build_search_atom({ 1 => [1, 8], 2 => [1] }).weightings(10)
    assert_in_delta(3.2188758248682, weightings[1], 2 ** -20)
    assert_in_delta(1.6094379124341, weightings[2], 2 ** -20)
  end
  
  private
  
  def build_search_atom(records = { 123 => [2,23,78] })
    search_atom = SearchAtom.new
    records.each do |record_id, positions|
      search_atom.add_record(record_id)
      positions.each do |position|
        search_atom.add_position(record_id, position)
      end
    end
    search_atom
  end
  
end
