require_relative "remedy.rb"
require_relative "game.rb"
require_relative "board.rb"
require_relative "position_methods.rb"

class Controller

	include Position_Methods

	attr_reader :game, :board, :word_arrays

	def initialize
		@word_arrays = create_word_arrays
	end

#### INPUT RESPONSE METHODS ####

	def select_cell
		swap1 = [ game.game_state[flat_index(game.cursor_coords[1])], flat_index(game.cursor_coords[1])  ]
		swap2 = [ game.game_state[flat_index(game.cursor_coords[0])], flat_index(game.cursor_coords[0])  ]
		game.game_state[swap2[1]] = swap1[0]
		game.game_state[swap1[1]] = swap2[0]
	end

	def change_cursor(direction)
		case direction
		when "left"
			if game.cursor_coords[0][0] > 0 && game.cursor_coords[1][0] > 0
				if game.cursor_coords[1][0] < game.cursor_coords[0][0]
					switch_cursor
				end
				game.cursor_coords[0][0] -= 1
				game.cursor_coords[1][0] -= 1
			end
		when "right"
			if game.cursor_coords[1][0] < 6 && game.cursor_coords[0][0] < 6
				game.cursor_coords[0][0] += 1
				game.cursor_coords[1][0] += 1
			end
		when "up"
			if game.cursor_coords[0][1] > 0 && game.cursor_coords[1][1] > 0
				if game.cursor_coords[1][1] < game.cursor_coords[0][1] 
					switch_cursor
				end
				game.cursor_coords[0][1] -= 1
				game.cursor_coords[1][1] -= 1
			end
		when "down"
			if game.cursor_coords[1][1] < 7  && game.cursor_coords[0][1] < 7
				game.cursor_coords[0][1] += 1
				game.cursor_coords[1][1] += 1
			end
		end
	end

	def switch_cursor
		swap1 = [game.cursor_coords[0][0], game.cursor_coords[0][1]]
		swap2 = [game.cursor_coords[1][0], game.cursor_coords[1][1]]
		game.cursor_coords[0] = swap2
		game.cursor_coords[1] = swap1
	end

	def rotate_cursor
		if game.cursor_orientation == "horizontal"
			if game.cursor_coords[0][1] < 7 && game.cursor_coords[1][1] < 7
				game.cursor_coords[1] = [game.cursor_coords[0][0], game.cursor_coords[0][1] + 1]
			else
				game.cursor_coords[1] = [game.cursor_coords[0][0], game.cursor_coords[0][1] - 1]
			end
			game.cursor_orientation = "vertical"
		elsif game.cursor_orientation == "vertical"
			if game.cursor_coords[0][0] < 6 && game.cursor_coords[1][0]
				game.cursor_coords[1] = [game.cursor_coords[0][0] +1, game.cursor_coords[0][1]]
			else
				game.cursor_coords[1] = [game.cursor_coords[0][0] -1, game.cursor_coords[0][1]]
			end
			game.cursor_orientation = "horizontal"
		end
	end

#### EVALUATE LETTERS METHODS ####

	def create_string(choice, index)
		word_array = []
		if choice == "row"
			find_row(index).each do |index2|
			  word_array << game.game_state[index2]
			end
		else
			find_column(index).each do |index2|
			  word_array << game.game_state[index2]
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

#### TURN METHODS ####

	def user_input
		input = show_single_key
			case input
			when "LEFT ARROW"
				change_cursor("left")
			when "RIGHT ARROW"
				change_cursor("right")
			when "UP ARROW"
				change_cursor("up")
			when "DOWN ARROW"
				change_cursor("down")
			when "SINGLE CHAR HIT: \"f\""
				select_cell
				gravity
			when "SINGLE CHAR HIT: \"e\""
				add_row(1)
			when "ESCAPE"
				return false
			when "SINGLE CHAR HIT: \"g\""
				rotate_cursor
			when "RETURN"
				evaluate_board
				gravity
			end
	end

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
		number.times do 
			if game.game_state.count == 56
				7.times { game.game_state.shift }
				game.game_state = game.game_state + make_row.shuffle 
			else 
				game.game_state = game.game_state + make_row.shuffle
			end
		end
		(56 - game.game_state.count).times { game.game_state.unshift(" ") }
	end

	def new_game
		@game = Game.new([[3, 6], [4, 6]], "horizontal")
		add_row(3)
		@board = Board.new
	end

	def start_game
		new_game
		@board.display_board(@game)
		while user_input != false
    	@board.display_board(@game)
    # 	p game.score
    # 	p game.words_matched
		end
	end

	def gravity
		repeat = false
		game.game_state.each.with_index do |cell, i|
			if i < 49 && cell != " " && game.game_state[(i + 7)] == " "
				game.game_state[i], game.game_state[(i + 7)] = game.game_state[(i + 7)], game.game_state[i]
				repeat = true
			end
		end
		if repeat == true
			gravity
		end
	end

    def flicker(cells)
        flickered_cells = {}
        cells.each do |cell|
            flickered_cells[cell] = game.game_state[cell]
            game.game_state[cell] = "*"
        end
        @board.display_board(@game)
        sleep(0.5)
        flickered_cells.each do |k,v|
            game.game_state[k] = v
        end
        @board.display_board(@game)
        sleep(0.5)
    end

    def clear_cells(cells)
        cells.each do |cell|
            game.game_state[cell] = " "
        end
    end

	def update_score(words)
        if words[1] 
		    game.score += words[1]
		    words[0].each {|word| game.words_matched << word}
        end
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
		flicker(marked_cells.uniq)
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

# pass row or column in to be evaluated
# create string out of row/column
# test string against appropriate word_list(s)
# calculate and return highest scoring, non overlapping words
# add score to score_total
# match returned word to positions in row/column array 
# mark cells to be erased by adding coordinates to erase_cells array
# check other rows/columns & repeat above
# after all other rows and columns have been checked, clear contents of erase_cells array





# Calculate and store total possible value of string
# Create empty hash
# test_words_array
# Grab highest scoring word
# create word_array
# Count how many times highest scoring word occurs in word_list
# if highest scoring word occurs more times in word_list than in tested_words_array, put in tested_words_array
# Place word into word_array
# Place word_array into hash as value with score as value
# Remove word from string (using slice!)
# Repeat until no words are left
# Store total value
# if stored_total_score == total_possible_score, move to next section
# Otherwise, repeat until texted_words_array.count equals word_list





# (0..6).each do |index|
# if /\S/.match(create_string("column", index)[0])
# 	match_string(create_string("column", index))

# (0..7).each do |index| 
# 	if /\S/.match(create_string("row", index)[0])
# 	match_string(create_string("row", index))


	# def score_words(word_list)
	# 	overlapping_words = []
	# 	word_list.each do |word1|
	# 		word_list.each do |word2|
	# 			if word1 == word2
	# 				next
	# 			elsif word2.include?(word1)
	# 				overlapping_words << word2
	# 				overlapping_words << word1
	# 			end
	# 		end
	# 	end
	# 	overlapping_words
	# 	# Check if words overlap with other words in list
	# 	# If words overlap
	# 	# Calculate each word's value
	# end

	# def create_strings(game)
	#     word_list = {}
	#     (0..7).each do |row|
	#         word_array = []
	#         find_row(row).each do |index|
	#             word_array << game.game_state[index]
	#         end
	#         if /\S/.match(word_array.join)
	#             word_list["row#{row}"] = word_array.join("")
	#         end
	#    end
	#    (0..6).each do |col|
	#         word_array = []
	#         find_column(col).each do |index|
	#             word_array << game.game_state[index]
	#         end
	#         if /\S/.match(word_array.join)
	#             word_list["col#{col}"] = word_array.join("")
	#         end
	#     end
	#     word_list
	# end