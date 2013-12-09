#require "./sim.rb"
class Car
	attr_reader :x,:y,:carState,:a
	attr_accessor :carBehind
	module CarState
		ACCELERATING = 1
		DECELERATING = -1
		CONSTANT = 0
	end
	def initialize(maxSpeed,maxAcceleration,time,aheadCar,leftMoving)
		
		@carState = CarState::CONSTANT
		@eventCounter = 1
		@leftMoving = leftMoving
		@minExitTime =  time + (7 * 330).to_f/speed
		@maxSpeed = maxSpeed
		@maxA = maxAcceleration
		@a = maxAcceleration
		@carBehind = nil
		@speed = maxSpeed
		aheadCar.carBehind = self
		if @leftMoving
			@x = 7 * 330
			@y = 28
		else
			@x = 0
			@y = 5
		end
		#evaluate(aheadCar)
	end
	def evaluate(aheadCar)
		state = @carState
		if minSafeDistance(self, aheadCar)
			if aheadCar.carState == CarState::ACCELERATING and @speed.abs < @maxSpeed.abs
				if aheadCar.a.abs >= @maxA.abs
					@a = @maxA
					@carState = CarState::ACCELERATING
				else
					@carState = CarState::ACCELERATING
					@a = aheadCar.a
				end
			elsif aheadCar.carState == CarState::DECELERATING
				@carState = CarState::DECELERATING
				@a = aheadCar.a
			elsif aheadCar.carState == CarState::CONSTANT
				if aheadCar.speed.abs >= @speed.abs
					@carState = CarState::CONSTANT
				else
					@carState = CarState::DECELERATING
				end
			end
		else
			if @speed.abs < @maxSpeed.abs
				@carState = CarState::ACCELERATING
			else
				@carState = CarState::CONSTANT
			end
		end
	end
end