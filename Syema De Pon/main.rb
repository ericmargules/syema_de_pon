require 'gosu'
require_relative 'position_methods.rb'
require_relative "game.rb"
require_relative "board.rb"

class GameWindow < Gosu::Window

	include Position_Methods

	def initialize(width, height, fullscreen)
		super(width, height, fullscreen)
		@word_arrays = create_word_arrays
		@pause_screen = Gosu::Image.new(self, "images/pause_screen.png", false)
		@pause_icon = Gosu::Image.new(self, "images/pause_icon.png", false)
		new_game(self)
	end

	def new_game(window)
		@game = Game.new([[3, 6], [4, 6]], "horizontal", window)
		@board = Board.new(window)
		add_row(3)
	end

  def needs_cursor?
    true
  end

  def button_down(id)
		if @game.pause
			case id
			when Gosu::KbEscape then pause
			when Gosu::KbUp
				@icon_pos == 0 ? @icon_pos = 2 : @icon_pos -= 1
			when Gosu::KbDown
				@icon_pos == 2 ? @icon_pos = 0 : @icon_pos += 1
			when Gosu::KbReturn 
				case @icon_pos
				when 0
					pause
				when 1
					new_game(self)
				when 2
					game_over
				end
	  	end
	  else
	  	case id
	  	when Gosu::KbEscape then pause
	  	when Gosu::KbLeft then change_cursor("left")
	  	when Gosu::KbRight then change_cursor("right")
	  	when Gosu::KbUp then change_cursor("up")
	  	when Gosu::KbDown then change_cursor("down")
	  	when Gosu::KbE then add_row(1)
	  	when Gosu::KbF then select_cell
	  	when Gosu::KbG then rotate_cursor
	  	when Gosu::KbReturn then evaluate_board
	  	end
	  end
  end

	def update
		@game.game_timer.update
		gravity
		pressurize
		check_pressure
		accelerate(@game)
	end

	def draw
		@board.display_board(@game)
		draw_pause(@game)
	end

	
	#### GAME STATE METHODS ####

	def make_row
		row = []
		rand(1..2).times { row << vowels.sample }
		rand(2..4).times { row << commons.sample }
		if rand(0..1) == 1
			row << rares.sample
		end
		(7 - row.count).times { row << uncommons.sample }
		row
	end
	
	def add_row(number)
		if @game.pressure == true
			game_over
		else
			number.times do 
				if @game.game_state.count == 56
					7.times { @game.game_state.shift }
					@game.game_state = @game.game_state + make_row.shuffle 
				else 
					@game.game_state = @game.game_state + make_row.shuffle
				end
			end
			(56 - @game.game_state.count).times { @game.game_state.unshift(" ") }
		end
	end

	def gravity
		repeat = false
		@game.game_state.each.with_index do |cell, i|
			if i < 49 && cell != " " && @game.game_state[(i + 7)] == " "
				@game.game_state[i], @game.game_state[(i + 7)] = @game.game_state[(i + 7)], @game.game_state[i]
				repeat = true
			end
		end
		if repeat == true
			gravity
		end
	end

 	def clear_cells(cells)
    cells.each do |cell|
    	@game.game_state[cell] = " "
  	end
  end


	def update_score(words)
  	if words[1] 
			@game.score += words[1]
			words[0].each {|word| @game.words_matched << word}
    end
	end

	def pressurize
		if /\S/.match(create_string("row", 0)) 
			@game.pressure = true 
		else
			@game.pressure = false
			@timer_now = nil
			@timer_start = nil
		end
	end

	def check_pressure
		if @game.pressure == true
			if @timer_start 
				@timer_now = Time.now
			else
				@timer_start = Time.now
			end
			if @timer_now
				if (@timer_now - @timer_start) >= 3
					game_over
				end
			end
		end
	end

	def accelerate(game)
		case 
		when game.game_timer.minutes <= 2
			if game.game_timer.seconds % 30 == 0 && game.game_timer.seconds != game.last 
				add_row(1)
				game.last = game.game_timer.seconds
			end
		when game.game_timer.minutes <= 3
			if game.game_timer.seconds % 20 == 0 && game.game_timer.seconds != game.last 
				add_row(1)
				game.last = game.game_timer.seconds
			end
		when game.game_timer.minutes <= 4
			if game.game_timer.seconds % 15 == 0 && game.game_timer.seconds != game.last 
				add_row(1)
				game.last = game.game_timer.seconds
			end		
		when game.game_timer.minutes <= 5
			if game.game_timer.seconds % 10 == 0 && game.game_timer.seconds != game.last 
				add_row(1)
				game.last = game.game_timer.seconds		
			end
		when game.game_timer.minutes >= 5
			if game.game_timer.seconds % 5 == 0 && game.game_timer.seconds != game.last 
				add_row(1)
				game.last = game.game_timer.seconds		
			end
		end
	end

	def game_over
		close
		p @game.game_timer
	end

#### WORD CALCULATION METHODS ####


	def create_string(choice, index)
		word_array = []
		if choice == "row"
			find_row(index).each do |index2|
			  word_array << @game.game_state[index2]
			end
		else
			find_column(index).each do |index2|
			  word_array << @game.game_state[index2]
			end
		end
		word_array.join
	end

	def check_string(string)
		word_list = []
            if /[AEIOU]/.match(string)
            alphabet = [*("A".."Z")]
            array = string.split("")
            array.pop
            array.uniq.each do |letter|
                if letter == " "
			           next
			    else
    		   		@word_arrays[alphabet.index(letter)].each do |word|
    					if string.include?(word)
    						(string.scan(/(?=#{word})/).count).times { word_list << word }
    					end
    				end
                end
			end	
		else 
			if /[Y]/.match(string)
				@word_arrays[-1].each do |word|
					if string.include?(word)
						(string.scan(/(?=#{word})/).count).times { word_list << word }
					end
				end
			else
				@word_arrays[-2].each do |word|
					if string.include?(word)
						(string.scan(/(?=#{word})/).count).times { word_list << word }
					end
				end
			end
		end
		[word_list, string]
	end

	def calculate_word_score(string)
		string.split("").inject(0) do |memo, letter|
			memo += letter_values[letter]
		end
	end

	def calculate_array_score(array)
		array.inject(0) do |memo, word|
			memo += calculate_word_score(word)
		end
	end
	
	def find_best_combo(word_array, string, chosen_words, possibilities)
		word_array.each do |word|
			chosen_words2 = chosen_words.clone
			string2 = string.clone
			word_array2 = word_array.clone
			chosen_words2 << word
			string2.slice!(word)
			word_array2.delete_at(word_array2.index(word))
			word_array3 = []
			word_array2.each do |word2|
				if string2.include?(word2) 
					word_array3 << word2
				end
			end
			if word_array3 == [] 
				possibilities[chosen_words2] = calculate_array_score(chosen_words2)
			else 
				find_best_combo(word_array3.clone, string2.clone, chosen_words2.clone, possibilities)
			end
		end
	end
	
	def best_words(word_array, string)
		possibilities = {}
		chosen_words = []
		find_best_combo(word_array, string, chosen_words, possibilities )
		[possibilities.key(possibilities.values.sort[-1]), possibilities.values.sort[-1]]
	end

	def get_string_indices(words, string)
		array = []
		if words[0]
    		words[0].each do |word|
	    	x = 0
		    	if word
			        (word.length).times do 
			        	array << (string.index(word) + x)
			    	    x += 1
		        	end
		    	end
		    end
		end
		array
	end 

	def mark_cells(string_indices, board_index, choice)
		cells = []
		if choice == "row"
			string_indices.each do |index|
				cells << find_row_cell(index, board_index)
			end
		else
			string_indices.each do |index|
				cells << find_column_cell(index, board_index)
		    end
		end
		cells
	end


#### INPUT RESPONSE METHODS ####

	def select_cell
		swap1 = [ @game.game_state[flat_index(@game.cursor_coords[1])], flat_index(@game.cursor_coords[1])  ]
		swap2 = [ @game.game_state[flat_index(@game.cursor_coords[0])], flat_index(@game.cursor_coords[0])  ]
		@game.game_state[swap2[1]] = swap1[0]
		@game.game_state[swap1[1]] = swap2[0]
	end

	def change_cursor(direction)
		case direction
		when "left"
			if @game.cursor_coords[0][0] > 0 && @game.cursor_coords[1][0] > 0
				if @game.cursor_coords[1][0] < @game.cursor_coords[0][0]
					switch_cursor
				end
				@game.cursor_coords[0][0] -= 1
				@game.cursor_coords[1][0] -= 1
			end
		when "right"
			if @game.cursor_coords[1][0] < 6 && @game.cursor_coords[0][0] < 6
				@game.cursor_coords[0][0] += 1
				@game.cursor_coords[1][0] += 1
			end
		when "up"
			if @game.cursor_coords[0][1] > 0 && @game.cursor_coords[1][1] > 0
				if @game.cursor_coords[1][1] < @game.cursor_coords[0][1] 
					switch_cursor
				end
				@game.cursor_coords[0][1] -= 1
				@game.cursor_coords[1][1] -= 1
			end
		when "down"
			if @game.cursor_coords[1][1] < 7  && @game.cursor_coords[0][1] < 7
				@game.cursor_coords[0][1] += 1
				@game.cursor_coords[1][1] += 1
			end
		end
	end

	def switch_cursor
		swap1 = [@game.cursor_coords[0][0], @game.cursor_coords[0][1]]
		swap2 = [@game.cursor_coords[1][0], @game.cursor_coords[1][1]]
		@game.cursor_coords[0] = swap2
		@game.cursor_coords[1] = swap1
	end

	def rotate_cursor
		if @game.cursor_orientation == "horizontal"
			if @game.cursor_coords[0][1] < 7 && @game.cursor_coords[1][1] < 7
				@game.cursor_coords[1] = [@game.cursor_coords[0][0], @game.cursor_coords[0][1] + 1]
			else
				@game.cursor_coords[1] = [@game.cursor_coords[0][0], @game.cursor_coords[0][1] - 1]
			end
			@game.cursor_orientation = "vertical"
		elsif @game.cursor_orientation == "vertical"
			if @game.cursor_coords[0][0] < 6 && @game.cursor_coords[1][0]
				@game.cursor_coords[1] = [@game.cursor_coords[0][0] +1, @game.cursor_coords[0][1]]
			else
				@game.cursor_coords[1] = [@game.cursor_coords[0][0] -1, @game.cursor_coords[0][1]]
			end
			@game.cursor_orientation = "horizontal"
		end
	end

	def pause
		@game.game_timer.pause
		@game.pause == false ? @game.pause = true : @game.pause = false
		@icon_pos = 0
	end

	def draw_pause(game)
		if game.pause == true
			@pause_screen.draw(280,160,3)
			place_pause_icon(@icon_pos)
		end
	end

	def place_pause_icon(position=0)
		@pause_icon.draw(440, (335 + (65 * position)), 4)
	end

	def evaluate_board
		marked_cells = []
		(0..7).each do |num|
			string = create_string("row", num)
			if string.include?("      ") 
				next 
			else
				words = best_words(check_string(string)[0],string)
				update_score(words)
				marked_cells += mark_cells(get_string_indices(words, string), num, "row")
			end
		end
		(0..6).each do |num|
			string = create_string("column", num)
			if string.include?("       ") 
				next
			else
				words = best_words(check_string(string)[0],string)
				update_score(words)
				marked_cells += mark_cells(get_string_indices(words, string), num, "column")
			end
		end
#		flicker(marked_cells.uniq)
		clear_cells(marked_cells.uniq)
	end


	private

	def create_word_arrays
		word_arrays = []
		[*("a".."z")].each do |letter|
			letter_array = []
			IO.foreach("word_list/word_list_#{letter}.txt") do |line|
				letter_array << line.chomp.upcase
			end
			word_arrays << letter_array
		end
		letter_array = []
		IO.foreach("word_list/word_list_vowels.txt") do |line|
				letter_array << line.chomp.upcase
		end
		word_arrays << letter_array
		letter_array = []
		IO.foreach("word_list/word_list_y_vow.txt") do |line|
			letter_array << line.chomp.upcase
		end
		word_arrays << letter_array
		word_arrays
	end

	def vowels
		["A", "E", "I", "O", "U"]
	end

	def commons
		["N", "R", "T", "L", "S", "D", "G"]
	end

	def uncommons
		["B", "C", "M", "P", "F", "H", "V", "W", "Y"]
	end

	def rares
		["K", "J", "X", "Q", "Z"]
	end

	def letter_values
		{"A" => 1, "B" => 3, "C" => 2, "D" => 2, "E" => 1, "F" => 4, "G" => 2, "H" => 4, "I" => 1, "J" => 9, "K" => 6, "L" => 1, "M" => 3, "N" => 1, "O" => 1, "P" => 3, "Q" => 10, "R" => 1, "S" => 1, "T" => 1, "U" => 1, "V" => 4, "W" => 4, "X" => 8, "Y" => 4, "Z" => 10 } 
	end

end

game_window = GameWindow.new(1200, 720, false)
game_window.show

