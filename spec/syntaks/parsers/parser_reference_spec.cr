require "../../spec_helper"

module ParserReferenceTests
  class AcceptanceTest < Minitest::Test
    class TestParser < Syntaks::FullParser

      def root
        list
      end

      def list
        @list ||= ParserReference(Array(Int32)).new "list", ->{
          AlternativeParser.new(
            TokenParser.new(".", ->(s : String){ [] of Int32 }),
            SequenceParser.new(
              list_item,
              list as ParserReference(Array(Int32)),
              ->(args : {Int32, Array(Int32)}){ [args[0]] + args[1] }
            )
          )
        }
      end

      def list_item
        @list_item ||= ParserReference(Int32).new "list_item", ->{
          SequenceParser.new(
            TokenParser.new(/\d+/, ->(s : String){ s.to_i }),
            TokenParser.new(","),
            ->(args : {Int32, String}){ args[0] }
          )
        }
      end

    end

    def test_full_match
      assert TestParser.new.call("123,666,1337,99955,.").full_match?
    end

    def test_result
      r = TestParser.new.call("123,666,1337,99955,.") as Syntaks::ParseSuccess(Array(Int32))
      assert r.value == [123, 666, 1337, 99955]
    end

  end
end
