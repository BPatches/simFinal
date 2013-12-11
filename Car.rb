#require "./sim.rb"
class Car
  attr_reader :x,:y,:carState,:a,:speed,:maxA,:leftMoving, :changeStratCount, :minExitTime
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
    @changeStratCount = 0

    if aheadCar != nil
      aheadCar.carBehind = self
    end
    @hasToStop = false
    if @leftMoving
      @x = 0
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
    return @speed + @a * @carState * (time -@lastTime)
  end
  def evaluate(engine)
    @x = getPos(engine.time)[0]
    @speed = (engine.time-@lastTime)*@a * @carState + @speed
    oldState = @carState
    @lastTime = engine.time
=begin
    if (@speed.abs - @maxSpeed.abs > 1)
      puts "********YOU DONE GOOFED************"
      puts @speed
      puts @maxSpeed
      puts "***********************************"
    end
    if @speed.abs > @maxSpeed.abs then
      @speed = @maxSpeed
    end
    @lastTime = engine.time
    engine.cullEvents(self)
    oldState = @carState
    if minSafeDistance(@aheadCar,engine)
      if @aheadCar.carState == CarState::ACCELERATING 
        if @speed.abs < @maxSpeed.abs
          if @aheadCar.a.abs >= @maxA.abs
            @carState = CarState::ACCELERATING
            @a = @maxA
          else
            @carState = CarState::ACCELERATING
            @a = @aheadCar.a
          end
        else   
          @carState = CarState::CONSTANT
          @a = 0
          @speed = @maxSpeed
        end
      elsif @aheadCar.carState == CarState::CONSTANT
        if (@aheadCar.getSpeed(engine.time) - @speed).abs < 0.3 
          @carState = CarState::CONSTANT
          @speed = @aheadCar.getSpeed(engine.time)
          puts "rounded to same"
        elsif @speed < @aheadCar.getSpeed(engine.time)
          if @speed.abs < @maxSpeed.abs
            @carState = CarState::ACCELERATING
            @a = @maxA
            puts "speeding up"
          else
            @CarState = CarState::CONSTANT
            @a = 0
            puts " can't go faster"
          end
        else
          if (@speed <=>0) == (@maxSpeed<=>0)
            @carState = CarState::DECELERATING
            @a = @maxA
            puts "slowing down"
          else
            @carState = CarState::CONSTANT
          end
        end
      elsif @aheadCar.carState == CarState::DECELERATING
        if (@speed <=>0) == (@maxSpeed<=>0)
          @a = [@aheadCar.a.abs,@maxA.abs].min*(@maxA<=>0.0)
        else
          @carState = CarState::CONSTANT
        end		
      end
    else
      if @speed.abs < @maxSpeed.abs
        @carState = CarState::ACCELERATING
        @a = @maxA
      else
        @carState = CarState::CONSTANT
      end
    end
=end
    if @hasToStop
      puts "Trying to stop"
      if @speed.abs < 0.01
        @carState = CarState::DECELERATING
        timeToStop = @speed / @maxA.to_f
        #engine.reCar(self,engine.time + timeToStop)
        @a = @maxA
      else
        @carState = CarState::CONSTANT
        @a = 0
        puts "STAPPPPPPPPPPPPPPPPPPPPPP"
        @speed = 0
      end
    else
      if minSafeDistance(@aheadCar,engine) then 
        if @aheadCar.carState == CarState::ACCELERATING 
          if @speed.abs < @maxSpeed.abs
            if @aheadCar.a.abs >= @maxA.abs
              @carState = CarState::ACCELERATING
              @a = @maxA
            else
              @carState = CarState::ACCELERATING
              @a = @aheadCar.a
            end         
          else   
            @carState = CarState::CONSTANT
            @a = 0
          end
        elsif @aheadCar.carState == CarState::DECELERATING
          @carState = CarState::DECELERATING
          @a = [@aheadCar.a.abs,@maxA.abs].min*(@maxA<=>0.0)
          if (@speed.abs > 0.01)
            engine.reCar(self,@speed.abs/@a.to_f.abs+0.1)#dat time
          else
            @carState = CarState::CONSTANT
            @speed = 0
            
          end
           
        elsif @aheadCar.carState == CarState::CONSTANT
          if @aheadCar.getSpeed(engine.time).abs >= @speed.abs
            @carState = CarState::CONSTANT
            @a = 0
          else
            @carState = CarState::DECELERATING
            @a = @maxA
            
            #puts @a.to_f
            engine.reCar(self,
                         ((@aheadCar.getSpeed(engine.time).abs-@speed.abs).abs + 0.001)/
                         @a.to_f.abs)#dat time
            #engine.addEvent(CarStop.new(self),engine.time + (@speed/@a).abs)
            
          end
        end
      else
        if @speed.abs < @maxSpeed.abs
          @carState = CarState::ACCELERATING
          
          @a = @maxA
          engine.reCar(self,((@maxSpeed.abs-@speed.abs).abs+0.001)/@a.to_f.abs)#dat time
          if (!@aheadCar == nil)
            engine.reCar(self,(@aheadCar.getSpeed(engine.time) - @speed).abs/@a)
            engine.reCar(self,
                         ((@x-@aheadCar.getPos(engine.time)[0]).abs -
                          (20 + 0.5 * @maxSpeed**2/(@maxA.abs.to_f)))/
                         (@maxSpeed-@aheadCar.getSpeed(engine.time)).abs)
          end
        else
          @carState = CarState::CONSTANT
          #puts " constant at #{@speed}"
          if @aheadCar != nil and @aheadCar.getSpeed(engine.time) < @speed
            engine.reCar(self,
                         ((@x-@aheadCar.getPos(engine.time)[0]).abs - 
                          (20 + 0.5 * @speed**2/(@maxA.abs.to_f)))/
                         (@speed-@aheadCar.getSpeed(engine.time)).abs)
          end 
        end
      end
      #           engine.reCar(self,0.1)
      d = 7*330-@x
      if ( a != 0 ) then
        engine.addEvent(CarDone.new(self), engine.time + (-@speed + Math.sqrt((@speed**2 + 2 * @a * d).abs))/@a)
      elsif (@speed != 0)
        engine.addEvent(CarDone.new(self), engine.time + (d/@speed))
      end
    end
    
    if @carState != oldState and carBehind != nil
      carBehind.evaluate(engine)
    end
    @changeStratCount += 1
    #      engine.reCar(self,0.5)

  end
  
  def minSafeDistance(otherCar,engine)
    if otherCar == nil
      return false#takes care of when car leaves simulation
    end
    #puts " dx: #{(@x - otherCar.x).abs}"
    #puts 20 + 0.5 * @speed**2/(@maxA.abs.to_f)

    if @x - otherCar.getPos(engine.time)[0] > 0
      puts "DAMNNN"
      puts engine.time
    end
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
