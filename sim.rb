require "./LRandom.rb"
require "./Welford.rb"

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

class CarSpawn < Event
  def apply(engine)
    speed = engine.rand.uniform(36.66,51.33,engine.carSpeed)
    newCar = Car.new(speed)
    engine.newCar(newCar)
    engine.add(CarSpawn.new(),engine.time + engine.rand.exponential(8,engine.carSpawn))
    engine.add(CarArrive.new(newCar),engine.time + (330*3.5-24/2)/speed)
  end
end

class CarArrive < Event
  def initialize(car)
    @car = car
  end

  def apply(engine)
    if engine.isGreen then
      engine.carWil.newData(0)
      engine.add(CarDone.new(@car),(330*3.5+24)/@car.speed)
    else
      @car.startWait(engine.time)
      engine.carWaiting.push(@car)
    end
  end
end

class CarDone < Event
  def initialize(car)
    @car = car
  end
  def apply(engine)
    engine.removeCar(@car)
  end
end

class PedSpawn < Event
  def apply(engine)
    speed = engine.rand.uniform(6,13,engine.pedSpeed)
    newPed = Ped.new(speed)
    engine.newPed(newPed)
    engine.add(PedSpawn.new(),engine.time + engine.rand.exponential(8,engine.pedSpawn))
    engine.add(PedArrive.new(newPed),engine.time + (engine.blockWidth/2)/speed)
  end
end

class PedArrive < Event
  def initialize(ped)
    @ped = ped
  end

  def apply(engine)

    if engine.isWalk then
      if engine.walkEnd - engine.time >= 46/@ped.speed then
        engine.add(PedDone.new(),engine.time + 46/@ped.speed)
        engine.pedWil.newData(0)
        return
      end
    end

    if engine.pedWaiting.length == 0 then
      if engine.rand.uniform(0,1,engine.pedPush) < 2.0/3.0 then
        engine.pushButton()
      end
    else
      if engine.rand.uniform(0,1,engine.pedPush) < 1.0/engine.pedWaiting.length then
        engine.pushButton()
      end
    end
    engine.add(ButtonPush.new(),engine.time + 60)
    @ped.beginWait(engine.time)
    engine.pedWaiting.push(@ped)
  end

end

class ButtonPush < Event
  def apply(engine)
    engine.pushButton
  end
end

class PedDone < Event
  def initialize(ped)
    @ped = ped
  end
  def apply(engine)
    engine.removePed(@ped)
  end
end

class SimEngine
  attr_reader :pedSpeed, :pedSpawn, :carSpeed, :carSpawn, :pedPush, :numPed, :numCar

  attr_accessor :pedWaiting, :carWaiting, :signal, :pedWil, :carWil, :rand, :time, :blockWidth, :finalTime

  def initialize(seed,endTime)
    @pedWaiting = []
    @carWaiting = []
    @signal = Light.new()
    @rand = LRandom.new(seed,5)
    @pedWil = Welford.new(10)
    @carWil = Welford.new(10)
    @pedSpawn = 0
    @pedSpeed = 1
    @carSpawn = 2
    @carSpeed = 3
    @pedPush = 4
    @time = 0
    @finalTime = endTime
    @eventsList = Array.new
    @numPed = 0
    @numCar = 0
    @blockWidth = 330
  end
  
  def newPed(ped)
    @numPed +=1
  end
  def newCar(car)
    @numCar +=1
  end
  def pushButton
    @signal.pushButton(self)
  end

  def isWalk
    return @signal.state == "RED"
  end

  def isGreen
    return @signal.state == "GREEN"
  end

  def walkEnd
    return @signal.endWalk - @time
  end

  def dumpButtonPush
    @eventsList.reject!{|item| item.class == ButtonPush}
  end

  def add(newEvent,time)
    newEvent.time = time
    if(newEvent.class == PedSpawn or newEvent.class == CarSpawn) then
      if time > @finalTime
        return
      end
    end
    @eventsList.push(newEvent)
    @eventsList.sort!
  end
  
  def nextEvent()
    return @eventsList.shift
  end

  def moreEvents
    return @eventsList.length > 0
  end

  def allowWalk()
    ped = @pedWaiting.shift
    while ped != nil do
      add( PedDone.new(ped),@time + 46/ped.speed)
      ped.endWait(@time)
      @pedWil.newData(ped.wait)
      ped = @pedWaiting.shift
    end
  end

  def allowDrive()
    car = @carWaiting.shift
    while car != nil do
      add(CarDone.new(car),(330*3.5+24)/car.speed)
      car.endWait(@time)
      @carWil.newData(car.wait)
      car = @carWaiting.shift
    end
  end

  def apply(event)
    @time = event.time
    event.apply(self)
  end

  def removePed(ped)
    return
  end

  def removeCar(ped)
    return
  end

end

class Light
  attr_reader :state, :endWalk
  def initialize()
    @state = "GREEN"
    @lastTransition=-100
  end

  def pushButton(engine)
    if @state == "GREEN" then
      if (engine.time - @lastTransition) < 14 then
        engine.add(GoYellow.new(),@lastTransition + 14)
      else
        engine.add(GoYellow.new(),engine.time + 1)
      end
    end
  end

  def goYellow(engine)
    @state = "YELLOW"
    engine.add(GoRed.new(),engine.time + 8)
    engine.dumpButtonPush()
  end

  def goRed(engine)
    @state = "RED"
    @endWalk = engine.time + 12
    engine.add(GoGreen.new(),engine.time + 12)
    engine.allowWalk()
    engine.dumpButtonPush()
  end

  def goGreen(engine)
    @state = "GREEN"
    @lastTransition = engine.time
    engine.allowDrive()
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
  end
end
class GoGreen < Event
  def apply(engine)
    engine.signal.goGreen(engine)
  end
end


class Ped
  attr_accessor :wait, :speed

  def initialize(speed)
    @speed = speed
    @wait = 0
  end

  def beginWait(time)
    @waitStart = time
  end

  def endWait(time)
    @wait = time - @waitStart
  end

end


class Car
  attr_accessor :wait, :speed

  def initialize(speed)
    @speed = speed
    @wait = 0
  end

  def startWait(time)
    @waitStart = time
  end

  def endWait(time)
    @wait = time - @waitStart
  end
end

class Runner
  def initialize(seed,time)
    @engine = SimEngine.new(seed,time)
    @engine.add(CarSpawn.new(),0)
    @engine.add(PedSpawn.new(),0)
  end
  def run
    while @engine.moreEvents do
      @engine.apply(@engine.nextEvent)
    end
    puts "Num peds"
    puts "OUTPUT #{@engine.numPed}"
    puts "Num cars"
    puts "OUTPUT #{@engine.numCar}"
    puts "time"
    puts "OUTPUT #{(@engine.time-@engine.finalTime)/60}"

    puts "min wait ped"
    puts "OUTPUT #{@engine.pedWil.min/60}"
    puts "average wait ped"
    puts "OUTPUT #{@engine.pedWil.xBar/60}"
    puts "sample stdev ped"
    puts "OUTPUT #{(@engine.pedWil.var/@engine.pedWil.i)/60}"
    puts "maximum wait ped"
    puts "OUTPUT #{@engine.pedWil.max/60}"

    puts "min wait car"
    puts "OUTPUT #{@engine.carWil.min/60}"
    puts "average wait car"
    puts "OUTPUT #{@engine.carWil.xBar/60}"
    puts "sample stdev car"
    puts "OUTPUT #{(@engine.carWil.var/@engine.carWil.i)/60}"
    puts "maximum wait car"
    puts "OUTPUT #{@engine.carWil.max/60}"

  end
end

a= Runner.new(ARGV[1].to_i,ARGV[2].to_i*60)
a.run
