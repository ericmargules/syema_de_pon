require 'gosu'
require_relative "tile.rb"
require_relative "number.rb"

class Board

include Position_Methods

def initialize(window)
		@background = Gosu::Image.new(window, "images/background.png", false)
		@pause_screen = Gosu::Image.new(window, "images/pause_screen.png", false)
		@pause_icon = Gosu::Image.new(window, "images/pause_icon.png", false)
		@tiles = Gosu::Image.load_tiles(window, "images/letters_spritesheet.png", 56, 52, false)
		@numbers = Gosu::Image.load_tiles(window, "images/numbers_spritesheet.png", 24, 28, false)
		@vert_cursor = Gosu::Image.new(window, "images/vert_cursor.png", false)
		@horz_cursor = Gosu::Image.new(window, "images/horz_cursor.png", false)
end

#### DISPLAY METHODS ####
			
	def display_board(game)
		draw_background
		draw_tiles(game)
		draw_cursor(game)
		draw_game_timer(game)
		draw_score(game)
	end

	def draw_background
		@background.draw(0,0,0)
	end

	def draw_tiles(game)
		game.game_state.each_with_index do |letter, index|
			z = coord(index)
			tile = Tile.new([(z[0] * 56) + 8, (z[1]*52) + 8], letter, @tiles)
			tile.draw
		end
	end

	def draw_cursor(game)
		if game.cursor_orientation == "horizontal"
			@horz_cursor.draw((game.cursor_coords.sort[0][0] * 56),(game.cursor_coords.sort[0][1] * 52),2)
		else	
			@vert_cursor.draw((game.cursor_coords.sort[0][0] * 56),(game.cursor_coords.sort[0][1] * 52),3)
		end
	end

	def draw_game_timer(game)
		game.game_timer.minutes.to_s.rjust(2, padstr="0").split("").each_with_index do |int, index|
			number = Number.new([(500 + (index * 30)), 25], int.to_i, @numbers)
			number.draw
		end	

		game.game_timer.seconds.to_s.rjust(2, padstr="0").split("").each_with_index do |int, index|
			number = Number.new([(570 + (index * 30)), 25], int.to_i, @numbers)
			number.draw
		end
	end

	def draw_score(game)
		game.score.to_s.split("").each_with_index do |int, index|
			number = Number.new([(500 + (index * 30)), 55], int.to_i, @numbers)
			number.draw
		end
	end
	
end