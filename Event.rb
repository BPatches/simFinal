require "./Ped.rb"
class Event
  attr_accessor :time
  
  def <=>(other)
    return @time <=> other.time
  end

  def initialize()
  end
  
  def apply(engine)
    return
  end
end

class CarE < Event
  attr_reader :car, :time
  def <=>(other)
    return @time <=> other.time
  end
end

class PedSpawn < Event
  def initialize(speed)
    #puts "Ped speed #{speed}"
    @speed = speed
  end

  def apply(engine)
    thisPed = Ped.new(@speed,engine.time)
    engine.addAgent(thisPed)
    engine.addEvent(
                    PedSpawn.new(engine.pedSpeed.getVal(engine.rand,$PEDSPEED)),
                    engine.pedArrive.nextArrival(engine.time/60, engine.rand, $PEDARRIVE)*60
                    )
  
    engine.addEvent(PedArrive.new(thisPed),engine.time + ($BLOCKWIDTH / (2.0 * @speed)))
  end
end

class PedArrive < Event
  def initialize(ped)
    @thisPed = ped
  end
  def apply(engine)
    @thisPed.x = $XWALKLOC
    if engine.isWalk and engine.walkEnd - $XWALKLENGTH/@thisPed.speed > 0 then
      engine.addEvent(PedDone.new(@thisPed),engine.time + $XWALKLENGTH/@thisPed.speed)
      @thisPed.movingDown(engine.time)
    else
      engine.tryPushButton()
      engine.addWaitingPed(@thisPed)
      @thisPed.moving(engine.time,false)
    end
  end
end

class PedDone < Event

  def initialize(ped)
    @thisPed = ped
  end

  def apply(engine)
    engine.removeAgent(@thisPed)
    engine.pedWil.newData(engine.time-@thisPed.minEnd)
  end
end

class ReEvalCar < CarE
  def initialize(car)
    @car = car
  end
  def apply(engine)
   # puts "something"
    @car.evaluate(engine)
  end
end
class CarSpawn < Event
def initialize(speed,acc,aheadCar,leftMoving)
    #puts "Ped speed #{speed}"
    if leftMoving
      @speed = -speed
      @acc = -acc
    else
      @speed = speed
      @acc = acc
    end
    @aheadCar = aheadCar
    @leftMoving = leftMoving
  end

  def apply(engine)

    thisCar = Car.new(@speed,@acc,engine.time,@aheadCar,@leftMoving)
    if @leftMoving
      if engine.frontLCar == nil
        engine.frontLCar = thisCar
      end
    else
      if engine.frontRCar == nil
        engine.frontRCar = thisCar
      end
    end
    thisCar.evaluate(engine)
    engine.addAgent(thisCar)
    engine.addEvent(
                    CarSpawn.new(engine.carSpeed.getVal(engine.rand,$CARSPEED),
                    engine.rand.uniform(7,12),thisCar,@leftMoving),
                    engine.carArrive.nextArrival(engine.time/60, engine.rand, $CARARRIVE)*60
                    )
   
    engine.addEvent(CarArrive.new(thisCar),engine.time + 
      (330*3.5 -12 - 0.5 * @speed**2/(@acc.abs.to_f))/@speed.abs)
  end
end

class LightCheck < CarE   
  def initialize(car)
    @car = car
  end
  def apply(engine)
    if engine.signal.state == 'RED'
      @car.stop
      @car.evaluate(engine)
    elsif  engine.signal.state == 'YELLOW'
      if !engine.canMakeItPassed(@car)
        @car.stop
        @car.evaluate(engine)
      end
    end
  end
end

class CarArrive < CarE
  def initialize(car)
    @car = car
  end
  def apply(engine)

  end
end
class CarStop < CarE
  def initialize(car)
    @car = car
  end
  def apply(engine)
    @car.stop
    engine.stoppedCars << self
  end
end





class CarDone < CarE
  def initialize(car)
    @car = car
  end
  def apply(engine)
    if @car.leftMoving
      if engine.frontLCar === @car
        engine.frontLCar = @car.carBehind
      end
    else
      if engine.frontRCar === @car
        engine.frontRCar = @car.carBehind
      end
    end
    engine.removeAgent(@car)
    engine.carWil.newData(engine.time-@car.minExitTime)
  end
end
class GoRed < Event
  def apply(engine)
    engine.signal.goRed(engine)
  end
end

class GoYellow < Event
  def apply(engine)
    engine.signal.goYellow(engine)
    #engine.lightStop
  end
end
class GoGreen < Event
  def apply(engine)
    engine.signal.goGreen(engine)
    #engine.lightGo
  end
end

class ButtonPush < Event
  def apply(engine)
    engine.pushButton
  end
end

class LogEvent < Event
  def apply(engine) 
    engine.addEvent(LogEvent.new(),engine.time + 0.1)
    carLog = []
    pedLog = []
    for agent in engine.agents
      if agent.class == Car
        carLog.push(agent.getPos(engine.time))
      else 
        pedLog.push(agent.getPos(engine.time))
      end
    end
    File.open(engine.logFile,"a") do |log|
      log.syswrite('{')
      for pos in carLog
        log.syswrite('(')
        log.syswrite(pos[0])
        log.syswrite(',')
        log.syswrite(pos[1])
        log.syswrite(')')	
      end
      log.syswrite('}')
      log.syswrite('{')
      for pos in pedLog
        log.syswrite('(')
        log.syswrite(pos[0])
        log.syswrite(',')
        log.syswrite(pos[1])
        log.syswrite(')')
      end
      log.syswrite('}')
      log.syswrite('{')
      log.syswrite(engine.signal.state)
      log.syswrite('}')
      log.puts
    end
  end
end
