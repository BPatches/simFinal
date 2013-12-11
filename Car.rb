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
  	@timeStep = 0.1

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
  end 
  def stop
    @hasToStop = true
  end
  def getSpeed(time)
    return @speed + @a *@carState * (time -@lastTime)
  end
  def safe(car,light)
  	dontNeedToStop = true
  	#if light
  	#	dontNeedToStop =  (330*3.5 - @x).abs > (20 + 0.5 * @speed**2/(@maxA.abs.to_f))
  	#end
  	if car == nil
  		return dontNeedToStop
  	end
  	puts (car.x - @x).abs
  	return ((car.x - @x).abs >= (20 + 0.5 * @speed**2/(@maxA.abs.to_f)) and dontNeedToStop)
  end
  def evaluate(engine)
  	@x = @x + (@speed * @timeStep)
  	@speed = @speed + (@maxA * @carState * @timeStep)
  	if !safe(@aheadCar,engine.lightState)
    	if (@speed <=>0.0) == (@maxA <=> 0.0)
    		@carState = CarState::DECELERATING
    	end
    else
    	if @speed.abs < @maxSpeed.abs
    		@carState = CarState::ACCELERATING
    	else
    		@carState = CarState::CONSTANT
    	end
    end
    #engine.reCar(self,@timeStep)
  end
  def minSafeDistance(otherCar,engine)
    if otherCar == nil
      return false#takes care of when car leaves simulation
    end
    #puts " dx: #{(@x - otherCar.x).abs}"
    #puts 20 + 0.5 * @speed**2/(@maxA.abs.to_f)
    return (@x - otherCar.getPos(engine.time)[0]).abs <= 20 + 0.5 * @speed**2/(@maxA.abs.to_f)+0.1
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
