class Bowl < ActiveRecord::Base
	belongs_to :player
   

    
	def roll(player_id)  	
		pins_hit = rand(1..10)
		
		if first_roll?(player_id) && pins_hit == 10
			self.score = 10
			self.turn += 2
		elsif first_roll?(player_id) 
			self.score = pins_hit
			self.turn += 1
		else
			self.score = 0
			pins_hit = rand(1..pins_left(player_id))
	   		self.score += pins_hit
			self.turn += 1

		end			
		self.strike_spare = spare_points(player_id)
		self.strike_spare += strike_points(player_id)


		# !spare_points.nil? ? self.strike_spare = spare_points : self.strike_spare = 0
		# strike_points.nil? ? self.strike_spare = 0 : self.strike_spare = strike_points
	end

	def first_roll?(player_id)
		turn_array(player_id).reduce(:+).nil? ? true : first_roll(player_id)
	end

	def self.total_score(player_id)
		###########################################################################################
		############################################################
		if Bowl.new.num_rolls(player_id) > 2
			Bowl.where(:player_id => player_id).all.map(&:strike_spare).reduce(:+) + Bowl.where(:player_id => player_id).all.map(&:score).reduce(:+)
		else 
			Bowl.where(:player_id => player_id).all.map(&:score).reduce(:+)
		end
	end

	def spare?(player_id)
		 scores_array(player_id).last(2).reduce(:+) == 10 && first_roll(1) unless scores_array(player_id).length <= 1
	end

	def first_roll(player_id)
		num_rolls(player_id) % 2 == 0
	end

	def spare_points(player_id)
		if num_rolls(player_id) > 3
			was_spare = scores_array(player_id)[-3..-2].reduce(:+) == 10 && !first_roll(player_id)
		elsif num_rolls(player_id) == 3 
			was_spare = scores_array(player_id)[0..1].reduce(:+) == 10
		else
			was_spare = false
		end
		was_spare ? scores_array(player_id)[-1] : 0
				
	end

	def strike?(player_id)
		scores_array(player_id).last == 10 
	end

	def strike_points(player_id)
		was_strike = scores_array(player_id)[-3] == 10 if num_rolls(player_id) >= 3 
		was_strike ? scores_array(player_id)[-2..-1].reduce(:+) : 0
	end

	def last_frame
		strike? ? scores_array(player_id).last : scores_array(player_id).last(2).reduce(:+)
	end


	def frame_number(player_id)
		#############################################3
		###############################################
		if num_rolls(player_id) >= 20
			10
		elsif num_rolls(player_id).nil?
			0
		else
			num_rolls(player_id) / 2 + 1
		end
	end

	def num_rolls(player_id)
		turn_array(player_id).empty? ? 0 : turn_array(player_id).reduce(:+)
	end

	def turn_array(player_id)
		Bowl.where(:player_id => player_id).all.map(&:turn) # array of turns
	end

	def scores_array(player_id)
		Bowl.where(:player_id => player_id).all.map(&:score)
	end

	def pins_left(player_id)
		10 - (scores_array(player_id).last)
	end

    
end
