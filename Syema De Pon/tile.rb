class Tile

	def initialize(coords, letter, sprites)
		letter != " " ? @image = sprites[letter.ord - 65] : @image = nil
		@x = coords[0]
		@y = coords[1]
	end

	def draw
		if @image
			@image.draw(@x, @y, 1)
		end
	end

end
