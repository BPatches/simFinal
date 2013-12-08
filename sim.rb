require "./LRandom.rb"
require "./Welford.rb"
require "./distributions.rb"

$PEDSTARTX = 100
$PEDSTARTY = 50
$XWALKLOC = 50

class Engine
  attr_reader :agents
  def initialize(seed,endTime,pedArriveF,carArriveF,pedSpeed,carSpeed)
    @pedWaiting = []
    @agents = []
    @signal = Light.new()
    @rand = LRandom.new(seed,5)
    @pedWil = Welford.new(20)
    @carWil = Welford.new(20)
    @carArrive = Lambda.new(carArriveF)
    @pedArrive = Lambda.new(pedArriveF)
    @pedSpeed = CustDistr.new(pedSpeed)
    @carSpeed = CustDistr.new(carSpeed)
    @time = 0
    @finalTime = endTime
    @eventsList = Array.new
    @numPed = 0
    @numCar = 0
    @blockWidth = 330
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
