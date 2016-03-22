require 'gosu'
require_relative "timer.rb"

class Game

	attr_accessor :game_state, :cursor_coords, :cursor_orientation, :last, :score, :words_matched, :pressure, :pause, :game_timer

	def initialize(cursor_coords, cursor_orientation, window)
		@cursor_coords = cursor_coords
		@cursor_orientation = cursor_orientation
		@game_state = []
		@pressure = false
		@last = 0
		@score = 0
		@words_matched = []
		@pause = false
		@game_timer = Timer.new(window)
	end

end