#require "./sim.rb"
class Car
	attr_reader :x,:y,:carState,:a,:speed,:maxA,:leftMoving
	attr_accessor :carBehind,:aheadCar
	module CarState
		ACCELERATING = 1
		DECELERATING = -1
		CONSTANT = 0
		STOP=3
	end
	def initialize(maxSpeed,maxAcceleration,time,aheadCar,leftMoving)
		@lastTime = time
		@carState = CarState::CONSTANT
		@eventCounter = 1
		@leftMoving = leftMoving
		@minExitTime =  time + (7 * 330).to_f/maxSpeed
		@maxSpeed = maxSpeed
		@maxA = maxAcceleration
		@a = maxAcceleration
		@carBehind = nil
		@speed = maxSpeed
		@aheadCar = aheadCar
		if aheadCar != nil
			aheadCar.carBehind = self
		end
		@hasToStop = false
		if @leftMoving
			@x = 7 * 330
			@y = 20
		else
			@x = 0
			@y = 5
		end
		
	end
	def start
		@hasToStop = false
		evaluate
	end 
	def stop
		@hasToStop = true
	end
	def evaluate(engine)
		@x = getPos(engine.time)[0]
		engine.cullEvents(self)
		if @hasToStop
			@carState = CarState::DECELERATING
		else
			#update state
		end
		engine.addLightCheck(self)

=begin	
		if stopping
			@hasToStop = stopping 
		end
		@x = getPos(engine.time)[0]
		@lastTime = engine.time
		engine.cullEvents(self)#cull dos events
		startState = @carState
		if !@hasToStop
			if minSafeDistance(@aheadCar)
				if @aheadCar.carState == CarState::ACCELERATING and @speed.abs < @maxSpeed.abs
					if @aheadCar.a.abs >= @maxA.abs
						@carState = CarState::ACCELERATING
						@a = @maxA
					else
						@carState = CarState::ACCELERATING
						@a = @aheadCar.a
					end
					nextX = getPos((@maxSpeed.abs-@speed.abs).abs/@a.to_f)[0]
					engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
				elsif @aheadCar.carState == CarState::DECELERATING
					@carState = CarState::DECELERATING
					@a = [@aheadCar.a.abs,@maxA.abs].min
					nextX = getPos(@speed.abs/@a.to_f)[0]
					engine.reCar(self,@speed.abs/@a.to_f,nextX)#dat time
					engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)
					
				elsif @aheadCar.carState == CarState::CONSTANT
					if @aheadCar.speed.abs >= @speed.abs
						@carState = CarState::CONSTANT
					else
						@carState = CarState::DECELERATING
						nextX = getPos((@aheadCar.speed.abs-@speed.abs).abs/@a.to_f)[0]
						engine.reCar(self,(@aheadCar.speed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
						engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)
						
					end
				end
			else
				if @speed.abs < @maxSpeed.abs
					@carState = CarState::ACCELERATING
					nextX = getPos((@maxSpeed.abs-@speed.abs).abs/@a.to_f)[0]
					engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f,nextX)#dat time
				else
					@carState = CarState::CONSTANT
				end
			end
		else
			@carState = CarState::DECELERATING
			@a = @maxA
			engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)
		end
		engine.addEvent(CarArrive.new(self),engine.time + 
      (330*3.5 -12 - (@x - 330*3.5).abs - 0.5 * @carState.abs*@speed**2/((@a).abs.to_f))/@speed.abs)
		if @carState != startState && @carBehind != nil
			@carBehind.evaluate(engine,@carBehind.getPos(engine.time))
		end
=end
	end
	def minSafeDistance(otherCar)
		if otherCar == nil
			return false#takes care of when car leaves simulation
		end
		return (@x - otherCar.x).abs <= 20 + 0.5 * @speed**2/(@maxA.abs.to_f)
	end
	def getPos(time)
		if @carState == CarState::STOP
			return [@x,@y]
		end
		elapsedTime = (time-@lastTime)
		x = elapsedTime**2*0.5*@carState*@a + @x + @speed*elapsedTime  
		return[x,@y]
	end
end
