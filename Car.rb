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
  def getSpeed(time)
    return @speed + @a *@carState * (time -@lastTime)
  end
  def evaluate(engine)
    @x = getPos(engine.time)[0]
    @speed = (engine.time-@lastTime)*@a * @carState + @speed
    if (@speed.abs - @maxSpeed.abs > 1)
      puts "********YOU DONE GOOFED************"
      puts @carState
      puts @speed
      puts @maxSpeed
      puts @a
      puts "***********************************"
    end
    @lastTime = engine.time
    engine.cullEvents(self)
    oldState = @carState
    if @hasToStop
      if @speed.abs < 0.01
        @carState = CarState::DECELERATING
        timeToStop = @speed / @maxA.to_f
        engine.reCar(self,engine.time + timeToStop)
        @a = @maxA
      else
        @carState = CarState::CONSTANT
        @a = 0
        puts "STAPPPPPPPPPPPPPPPPPPPPPP"
        @speed = 0
      end
    else
      if minSafeDistance(@aheadCar) then 
        if @aheadCar == nil or @aheadCar.carState == CarState::ACCELERATING 
          if @speed.abs < @maxSpeed.abs
            if @aheadCar == nil or @aheadCar.a.abs >= @maxA.abs
              @carState = CarState::ACCELERATING
              @a = @maxA
            else
              @carState = CarState::ACCELERATING
              @a = @aheadCar.a
            end
            puts 1
            engine.reCar(self,((@aheadCar.getSpeed(engine.time)-@speed.abs).abs+0.001)/@a.to_f.abs)#dat time
            engine.reCar(self,((@speed-@maxSpeed).abs+0.001)/@a.to_f.abs)#dat time
          else   
            @carState = CarState::CONSTANT
            @a = 0
          end
        elsif @aheadCar.carState == CarState::DECELERATING
          @carState = CarState::DECELERATING
          @a = [@aheadCar.a.abs,@maxA.abs].min*(@maxA<=>0.0)

          puts 2
          engine.reCar(self,@speed.abs/@a.to_f.abs)#dat time
          

        elsif @aheadCar.carState == CarState::CONSTANT
          if @aheadCar.getSpeed(engine.time).abs >= @speed.abs
            @carState = CarState::CONSTANT
            @a = 0
          else
            @carState = CarState::DECELERATING
            @a = @maxA
            puts 3

            #puts @a.to_f
            engine.reCar(self,((@aheadCar.getSpeed(engine.time).abs-@speed.abs).abs + 0.001)/@a.to_f.abs)#dat time
            engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)

          end
        end
      else
        if @speed.abs < @maxSpeed.abs
          @carState = CarState::ACCELERATING
          puts 4
          @a = @maxA
          engine.reCar(self,((@maxSpeed.abs-@speed.abs).abs+0.001)/@a.to_f.abs)#dat time
          if (!@aheadCar == nil)
            engine.reCar(self,(@aheadCar.getSpeed(engine.time)))
          end
        else
          @carState = CarState::CONSTANT
          #puts " constant at #{@speed}"
          if @aheadCar != nil and @aheadCar.getSpeed(engine.time) < @speed
            puts 5
            engine.reCar(self,((@x-@aheadCar.x)/(@speed-@aheadCar.getSpeed(engine.time))).abs)
          end
        end
      end
      
    end
    
    if @carState != oldState and carBehind != nil
      carBehind.evaluate(engine)
    end
    
  end
  def minSafeDistance(otherCar)
    if otherCar == nil
      return false#takes care of when car leaves simulation
    end
    #puts " dx: #{(@x - otherCar.x).abs}"
    #puts 20 + 0.5 * @speed**2/(@maxA.abs.to_f)
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
