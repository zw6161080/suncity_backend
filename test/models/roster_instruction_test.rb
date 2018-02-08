require "test_helper"

class RosterInstructionTest < ActiveSupport::TestCase

  def _roster_instruction
    @roster_instruction ||= RosterInstruction.new
  end

  def _test_valid
    assert roster_instruction.valid?
  end
end
