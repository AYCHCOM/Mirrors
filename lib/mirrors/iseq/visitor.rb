require 'mirrors/iseq/yasmdata'

module Mirrors
  module ISeq
    # Walks bytecode of methods and calls {#visit} for each instruction.
    # Internally it tracks the state of the current +@pc+, +@line+, and
    # +@label+ during the walk.
    #
    # @abstract Subclasses override {#visit}.
    class Visitor
      # Walk the given bytecode, invoking {#visit} for each instruction.
      # @param [RubyVM::InstructionSequence] native_code
      # @see MethodMirror#native_code
      # @return [Visitor] +self+. It's the side effects from {#visit} that are
      #   interesting.
      def call(native_code)
        @iseq = native_code

        # extract fields from iseq
        @magic,
        @major_version,
        @minor_version,
        @format_type,
        @misc,
        @label,
        @path,
        @absolute_path,
        @first_lineno,
        @type,
        @locals,
        @params,
        @catch_table,
        @bytecode = @iseq.to_a

        # walk state
        @pc = 0 # program counter
        @label = nil # current label
        walk
        self
      end

      # Invoked for each instruction as the bytecode stream is walked.
      # @abstract
      # @param [Array<Object>] _bytecode
      def visit(_bytecode)
        raise NotImplementedError, 'subclass responsibility'
      end

      private

      # walk the opcodes
      def walk
        return unless @bytecode # C extensions have no bytecode

        @pc = 0
        @label = nil
        @bytecode.each do |bc|
          case bc
          when Numeric
            @line = bc
          when Symbol
            @label = bc
          when Array # an actual instruction
            @opcode = YASMData.id2insn_no(bc.first)
            unrecognized_bytecode(bc) unless @opcode
            visit(bc)
            @pc += YASMData.insn_no2size(@opcode)
          end
        end
      end
    end
  end
end
