require 'gosu'
require_relative 'position_methods.rb'


class Tile

	def initialize(win, letter)
		@w = 42
		@h = 37
		@image = Gosu::Image.new(win, 'images/letters_spritesheet2.png', true)

		# letter == " " ? @image = Gosu::Image.load_tiles(win, "images/letters_spritesheet2.png", 42, 37, false)[26] : @image = Gosu::Image.load_tiles(win, "images/letters_spritesheet2.png", 42, 37, false)[letter.ord - 65]
	end

	def draw
		@image.draw(0, 0, 0, 0)
	end

end

class GameWindow < Gosu::Window

include Position_Methods

	def initialize width, height, fullscreen
		super(width, height, fullscreen)
		
		# @sprites = Gosu::Image.load_tiles(self, "images/letters_spritesheet2.png", 42, 37, true)
		@x = 15
		@y = 409
		@tile = Tile.new(self, "D")
	end

  def needs_cursor?
    true
  end

	def update

	end

	def draw
		x = 15
		y = 409
		
		@tile.draw
		# game_state = ["D", "Z", "A", "Q", "Z", "P"]
		# game_state.each do |letter|
		# 	z = coord(game_state.index(letter))
		# 		tile = Tile.new(self, letter)
		# 		tile.draw((x + (z[0] * 42)), (y + (z[1] * 37))) 
		# end
	end

	# def place_letters(game)
	# 	x = 15
	# 	y = 409
	# 	game.game_state.each do |letter|
	# 		z = coord(game_game_state.index(letter))
	# 		if @sprites[letter.ord - 65] != " "
	# 			@sprites[letter.ord - 65].draw((x + (z[0] * 42)), (y + (z[1] * 37))  ) 
	# 		else
	# 			@sprites[26].draw()
	# 		end
	# 	end
	# end


end

game_window = GameWindow.new(1200, 720, false)
game_window.show