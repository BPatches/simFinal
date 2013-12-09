#require "./sim.rb"
class Car
	attr_reader :x,:y,:carState,:a,:speed,:maxA
	attr_accessor :carBehind
	module CarState
		ACCELERATING = 1
		DECELERATING = -1
		CONSTANT = 0
	end
	def initialize(maxSpeed,maxAcceleration,time,aheadCar,leftMoving)
		@lastTime = time
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
	def evaluate(aheadCar,engine,pos)
		@x = pos
		@lastTime = engine.time
		engine.cullEvents(self)#cull dos events
		startState = @carState
		if minSafeDistance(aheadCar)
			if aheadCar.carState == CarState::ACCELERATING and @speed.abs < @maxSpeed.abs
				if aheadCar.a.abs >= @maxA.abs
					@a = @maxA
					@carState = CarState::ACCELERATING
				else
					@carState = CarState::ACCELERATING
					@a = aheadCar.a
				end
				nextX = getPos(@maxSpeed.abs-@speed.abs).abs/@a.to_f)[0]
				engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
			elsif aheadCar.carState == CarState::DECELERATING
				@carState = CarState::DECELERATING
				@a = [aheadCar.a.abs,@maxA.abs].min
				nextX = getPos(@speed.abs/@a.to_f)[0]
				engine.reCar(self,@speed.abs/@a.to_f,nextX)#dat time
			elsif aheadCar.carState == CarState::CONSTANT
				if aheadCar.speed.abs >= @speed.abs
					@carState = CarState::CONSTANT
				else
					@carState = CarState::DECELERATING
					nextX = getPos(aheadCar.speed.abs-@speed.abs).abs/@a.to_f)[0]
					engine.reCar(self,(aheadCar.speed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
				end
			end
		else
			if @speed.abs < @maxSpeed.abs
				@carState = CarState::ACCELERATING
				nextX = getPos(@maxSpeed.abs-@speed.abs).abs/@a.to_f)[0]
				engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
			else
				@carState = CarState::CONSTANT
			end
		end
		if @carState != startState
			@carBehind.evaluate(self,engine)
		end
	end
	def minSafeDistance(otherCar)
		if otherCar == nil
			return false#takes care of when car leaves simulation
		end
		return (@x - otherCar.x).abs <= 20 + 0.5 * @speed**2/(@maxA.abs.to_f)
	end
	def getPos(time)
		elapsedTime = (time-@lastTime)
		x = elapsedTime**2*0.5*@carState*@a + @x + @speed*elapsedTime  
		return[x,@y]
	end
end
