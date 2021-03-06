#!/usr/bin/env ruby
require 'open-uri'
require 'cli/ui'
require 'rss'

class NoOpNode
	attr_reader :name 
	def initialize(n)
		@name = n
	end
	def activate
	end
end

class MenuNode
	attr_reader :name, :children

	def initialize(name, children)
		@name = name
		@children = children
		@children['exit'] = NoOpNode.new('exit')
	end

	def activate
		answer = ''
		while answer != 'back' && answer != 'exit'
			answer = CLI::UI.ask(@name , options: @children.keys)
			@children[answer].activate
		end
	end
end

class RSSNode
	def initialize(name, address)
		@name = name
		@address = address
		@children = Hash.new
	end

	def activate
		if @children.empty?
			@children = fetch_rss(@address)
			@children['back'] = NoOpNode.new('back')
		end
		answer = ''
		while answer != 'back'
			answer = CLI::UI.ask(@name , options: @children.keys)
			@children[answer].activate
		end
	end

	private
	def fetch_rss(addr)
		feed = RSS::Parser.parse(open(addr))
		items = feed.items
		rss_items = items.map {|x| RSSItem.from_feed_item(x)}
		return rss_items.map {|item| [item.title, item]}.to_h
	end

end

class RSSItem
	def initialize(title, link, descr)
		@title = title
		@link = link
		@description = descr
	end

	def display
		CLI::UI.frame_style = :box
		puts @title
		puts @description
		puts @link
		puts
	end

	def activate()
		display
		answer = ''
		while answer != 'back'
			answer = CLI::UI.ask(@title, options: ['back'])
		end
	end
	def self.from_feed_item(item)
		title = ''
		description = ''
		link = ''
		if item.respond_to?(:title)
			title = item.title
		end
		if item.respond_to?(:description)
			description = item.description
			description.gsub!(/<\/?.*?>/,"")
		end
		if item.respond_to?(:link)
			link = item.link
		end
		RSSItem.new(title, description, link)
	end

	def self.from_nokogiri_item(xml_item)
		def self.get_content(elem)
			if elem.empty? || !elem[0].respond_to?(:content)
				nil
			else
				return elem[0].content
			end
		end
		title_elem = xml_item.children.select {|x| x.name == "title"}
		link_elem = xml_item.children.select {|x| x.name == "link"}
		descr_elem = xml_item.children.select {|x| x.name == "description"}
		title = RSSItem.get_content(title_elem)
		link = RSSItem.get_content(link_elem)
		descr = RSSItem.get_content(descr_elem)
		if title.nil?
			return nil
		else
			return RSSItem.new(title, link, descr)
		end
	end

	attr_reader :title, :link, :description
end

module Menu
	def self.load(fname)
		children = Hash.new
		File.foreach(fname) do |line|
			name, addr = line.split
			children[name] = RSSNode.new(name,addr)
		end
		MenuNode.new('Menu', children)
	end
end

