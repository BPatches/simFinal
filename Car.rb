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
  end 
  def stop
    @hasToStop = true
  end
  def evaluate(engine)
    @x = getPos(engine.time)[0]
    engine.cullEvents(self)
    if @hasToStop
      if @speed.abs > 0
        @carState = CarState::DECELERATING
        timeToStop = @speed / @maxA.to_f
        engine.reCar(self,@engine.time + timeToStop)
      else
        @carState = CarState::CONSTANT
      end
    else
      if minSafeDistance(@aheadCar)
        if @aheadCar.carState == Carstate::ACCELERATING and @speed.abs < @maxSpeed.abs
          if @aheadCar.a.abs >= @maxA.abs
            @carState = CarState::ACCELERATING
            @a = @maxA
          else
            @carState = CarState::ACCELERATING
            @a = @aheadCar.a
          end
          engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f)#dat time
        elsif @aheadCar.carState == CarState::DECELERATING
          @carState = CarState::DECELERATING
          @a = [@aheadCar.a.abs,@maxA.abs].min

          engine.reCar(self,@speed.abs/@a.to_f)#dat time
          engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)

        elsif @aheadCar.carState == CarState::CONSTANT
          if @aheadCar.speed.abs >= @speed.abs
            @carState = CarState::CONSTANT
          else
            @carState = CarState::DECELERATING

            engine.reCar(self,(@aheadCar.speed.abs-@speed.abs).abs/@a.to_f)#dat time
            engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)

          end
        end
      else
        if @speed.abs < @maxSpeed.abs
          @carState = CarState::ACCELERATING
          engine.reCar(self,(@maxSpeed.abs-@speed.abs).abs/@a.to_f)#dat time
        else
          @carState = CarState::CONSTANT
        end
      end
    end
    engine.addLightCheck(self)
    
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
