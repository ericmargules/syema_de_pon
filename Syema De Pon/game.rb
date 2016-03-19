class Game

	attr_accessor :game_state, :cursor_coords, :cursor_orientation, :score, :words_matched, :pressure, :pause

	def initialize(cursor_coords, cursor_orientation)
		@cursor_coords = cursor_coords
		@cursor_orientation = cursor_orientation
		@game_state = []
		@pressure = false
		@score = 0
		@words_matched = []
		@pause = false
	end

end