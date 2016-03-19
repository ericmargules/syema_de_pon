class Number

	def initialize(coords, number, sprites)
		@image = sprites[number]
		@x = coords[0]
		@y = coords[1]
	end

	def draw
		@image.draw(@x, @y, 1)
	end

end