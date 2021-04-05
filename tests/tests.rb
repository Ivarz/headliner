require 'minitest/autorun'
require_relative '../lib/nodes.rb'

module ActivateInterfaceTest
	def test_implements_activate_interface
		assert_respond_to(@object, :activate)
	end
end

class NoOpNodeTest < MiniTest::Test
	include ActivateInterfaceTest

	def setup
		@noop_node = @object = NoOpNode.new("")
	end
end

class MenuNodeTest < MiniTest::Test
	include ActivateInterfaceTest

	def setup
		@menu_node = @object = MenuNode.new("", Hash.new)
	end
end

class RSSNodeTest < MiniTest::Test
	include ActivateInterfaceTest

	def setup
		@rss_node = @object = RSSNode.new("", "")
	end
end

class RSSItemTest < MiniTest::Test
	include ActivateInterfaceTest

	def setup
		@rss_item = @object = RSSItem.new("", "", "")
	end
end

