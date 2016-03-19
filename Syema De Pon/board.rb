class Board

#### DISPLAY METHODS ####
	
	def make_board
	  board_array = []
	  IO.foreach("board.txt") {|line| board_array << line.chomp }
	  @board_string = board_array.join("\n")
	end

	def place_letters(game)
		x = 368
	  game.game_state.each do |letter|
	  	@board_string[x] = letter
	  		case x 
	  		when 416
	  			x += 316
	  		when 780
	  			x += 316
	  		when 1144
	  			x += 316
	  		when 1508
	  			x += 316
	  		when 1872
	  			x += 316
	  		when 2236
	  			x += 316	
	  		when 2600
	  			x += 316
	  		when 2964
	  			x += 316
	  		else
	  			x += 8
	  		end
	  end
	end
	
	def calc_cursor_array(coords, orientation)
			cursor_array = []
			x = 1
			y = 1 
		if orientation == "horizontal"	
			coords[0][0] < coords[1][0] ? coords = coords[0] : coords = coords[1]
			cursor_array << (((((coords[1] * 4) + 3)-1) * 91) + (coords[0] * 8)+1)	
			(1..14).each { |x| cursor_array << cursor_array[0] + x }
			(0..14).each { |x| cursor_array << cursor_array[0] + (x + 364) }
			3.times do
				cursor_array << cursor_array[0] + (91 * x)
				x += 1
			end
			3.times do
				cursor_array << cursor_array[4] + ((91 * y) + 10)
				y += 1
			end
		else
	 		coords[0][1] < coords[1][1] ? coords = coords[0] : coords = coords[1]
			cursor_array << (((((coords[1] * 4) + 3)-1) * 91) + (coords[0] * 8)+1)	
			(1..6).each { |x| cursor_array << cursor_array[0] + x }
			(0..6).each { |x| cursor_array << cursor_array[0] + (x + 728) }
			7.times do
				cursor_array << cursor_array[0] + (91 * x)
				x += 1
			end
			7.times do
				cursor_array << cursor_array[4] + ((91 * y) + 2)
				y += 1
			end
		end
			cursor_array
	end

	def mark_cursor_cell(cursor_array)
		cursor_array.each { |x| @board_string[x] = '#' }
	end
	
	def display_score(game)
		x = 355 - game.score.to_s.length
		game.score.to_s.split("").each do |int|
			@board_string[x] = int
			x += 1
		end
	end
			
	def display_board(game)
		make_board
		place_letters(game)
		mark_cursor_cell(calc_cursor_array(game.cursor_coords, game.cursor_orientation))
		display_score(game)
		system "clear" or system "cls"
		puts @board_string
	end
	
end