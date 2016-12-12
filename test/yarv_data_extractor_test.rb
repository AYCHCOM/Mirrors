require 'test_helper'

require_relative '../yarvdata/insnsdata'

class YARVDataExtractorTest < MiniTest::Test
  def setup
    datadir = File.expand_path('../../yarvdata', __FILE__)
    @yde = YARVDataExtractor.new(datadir + '/insns.inc', datadir + '/insns_info.inc')
  end

  NUM_INSTRUCTIONS = 94

  def test_operand_type
    assert_equal(:num, @yde.operand_type('N'))
  end

  def test_instruction_numbers
    data = @yde.instruction_numbers
    assert_equal(0, data[:nop])
    assert_equal(90, data[:setlocal_OP__WC__0])
    assert_equal(NUM_INSTRUCTIONS, data.size)
  end

  def test_operand_info
    data = @yde.operand_info
    assert_equal([], data[0])
    assert_equal([:lindex, :num], data[1])
    assert_equal([:lindex], data[90])
    assert_equal(NUM_INSTRUCTIONS, data.size)
  end

  def test_length_info
    data = @yde.length_info
    assert_equal(1, data[0])
    assert_equal(2, data[90])
    assert_equal(NUM_INSTRUCTIONS, data.size)
  end

  def test_stack_push_num_info
    data = @yde.stack_push_num_info
    assert_equal(0, data[0])
    assert_equal(0, data[90])
    assert_equal(NUM_INSTRUCTIONS, data.size)
  end

  def test_stack_increase
    data = @yde.stack_increase
    assert_equal(0, data[0])
    assert_equal(-1, data[90])
    assert_equal(:expandarray, data[26])
    assert_equal(:one_minus_op_0, data[20])
    assert_equal(NUM_INSTRUCTIONS, data.size)
  end
end
