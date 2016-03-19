require 'gosu'

class Timer
	attr_reader :hours
	attr_reader :minutes
	attr_reader :seconds
	
	def initialize(window)
		@hours = 0
		@minutes = 0
		@seconds = 0
		@last_time = Gosu::milliseconds()
		@pause = false
	end
	
	def update
		if @pause == false
			if (Gosu::milliseconds - @last_time) / 1000 == 1
				@seconds += 1
				@last_time = Gosu::milliseconds()
			end
			if @seconds > 59
				@seconds = 0
				@minutes += 1
			end
			if @minutes > 59
				@hours += 1
				@minutes = 0
			end
		end
	end

	def pause
		if @pause == false 
			@pause = true 
		else
			@pause = false
			@last_time = Gosu::milliseconds()
		end
	end

	def unpause

	end

end
