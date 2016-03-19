module Position_Methods

	def y_index(flat_index)
		flat_index / 7
	end

	def x_index(flat_index)
		flat_index % 7
	end
	
	def coord(flat_index)
		coordinates = x_index(flat_index), y_index(flat_index)
	end
	
	def flat_index(coordinates)
		 coordinates[0] + coordinates[1] * 7
	end

	def find_column(column_index)
		column = []
		(0..7).each { |x| column << (x * 7 + column_index) }
		column
	end

	def find_row(row_index)
		row = []
		(0..6).each { |x| row << (x + (row_index * 7)) }
		row
	end

	def find_row_cell(string_index, row_index)
		(row_index * 7) + string_index
	end

	def find_column_cell(string_index, column_index)
		(string_index * 7) + column_index
	end

end