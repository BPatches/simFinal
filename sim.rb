require "./LRandom.rb"
require "./Welford.rb"
require "./distributions.rb"
require "./Ped.rb"
require "./Car.rb"
require "./Event.rb"

$BLOCKWIDTH = 330
$PEDSTARTX = $BLOCKWIDTH*4 
$PEDSTARTY = 0
$XWALKLOC = $BLOCKWIDTH*3.5
$XWALKLENGTH = 46
$TOTALWALK = 330/2 + 46
$PEDSPEED = 0
$PEDARRIVE = 1
$PUSHBUTTON = 2
$CARSPEED = 3
$CARARRIVE = 4

class Engine
  attr_reader :agents , :rand, :pedArrive, :pedSpeed,:pedWil,:signal,:logFile,:time,:carSpeed,:carArrive,:frontLCar,:frontRCar
  attr_accessor :stoppedCars
  def initialize(endTime,seed,pedArriveF,carArriveF,
                 pedSpeedF,carSpeedF,logFile)
    @pedWaiting = []
    @agents = []
    @frontLCar = nil
    @frontRCar = nil
    @signal = Light.new()
    @rand = LRandom.new(seed,5)
    @pedWil = Welford.new(20)
    @carWil = Welford.new(20)
    @carArrive = Lambda.new(carArriveF)
    @pedArrive = Lambda.new(pedArriveF)
    @pedSpeed = CustDist.new(pedSpeedF)
    @carSpeed = CustDist.new(carSpeedF)
    @time = 0
    @finalTime = endTime
    @eventsList = Array.new
    @logFile = logFile
    @stoppedCars = []
    File.open(logFile,"w")
  end
  
  def addAgent(agent)
    @agents << agent
  end

  def addWaitingPed(ped)
    @pedWaiting << ped
  end

  def tryPushButton
    if @pedWaiting.length == 0 then
      if @rand.uniform(0,1,$PUSHBUTTON) < 2.0/3.0 then
        pushButton()
      end
    else
      if @rand.uniform(0,1,$PUSHBUTTON) < 1.0/@pedWaiting.length then
        pushButton()
      end
    end
    addEvent(ButtonPush.new(),@time + 60)
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
  def cullEvents(car)
    @eventsList.reject!{|event| 
     event.is_a?(CarE) and event.car == car 
    }
  end
  def addEvent(newEvent,time)
    newEvent.time = time
    if(newEvent.class == PedSpawn or newEvent.class == LogEvent)# or newEvent.class == CarSpawn) then
      if time > @finalTime
        return
      end
    end
    @eventsList.push(newEvent)
    @eventsList.sort!
  end
  def addLightCheck(car)
    if passedLight(car)
      return
    else
      addEvent(LightCheck.new(car),@time)
    end
  end
  def lightStop
    car = @frontRCar
    while canMakeItPassed(car)
      car = car.carBehind
    end
    @frontRCar = car
  end
  def lightGo

  end
  def passedLight(car)
    if car.leftMoving
      if car.x < $XWALKLOC-12
        return true
      end
      return false
    else
      if car.x > $XWALKLOC + 12
        return true
      end
      return false
    end
  end
  def canMakeItPassed(car)
    return false
  end
  def nextEvent()
    return @eventsList.shift
  end

  def moreEvents
    return @eventsList.length > 0
  end
  def reCar(car,time,newPos)
    addEvent(ReEvalCar.new(car,newPos),@time+time)
  end
  def allowWalk()
    ped = @pedWaiting.shift
    while ped != nil do
      ped.movingDown(@time)
      addEvent( PedDone.new(ped),@time + $XWALKLENGTH / ped.speed)
      ped = @pedWaiting.shift
    end
  end
  def allowDrive()
    return
  end

  def apply(event)
    @time = event.time
    event.apply(self)
  end

  def removeAgent(agent)
    @agents.delete(agent)
  end
  def startCars
    for car in @stoppedCars
      car.start
    end
    @stoppedCars = []
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
        engine.addEvent(GoYellow.new(),@lastTransition + 14)
      else
        engine.addEvent(GoYellow.new(),engine.time + 1)
      end
    end
  end

  def goYellow(engine)
    @state = "YELLOW"
    engine.addEvent(GoRed.new(),engine.time + 8)
    engine.dumpButtonPush()
  end

  def goRed(engine)
    @state = "RED"
    @endWalk = engine.time + 12
    engine.addEvent(GoGreen.new(),engine.time + 12)
    engine.allowWalk()
    engine.dumpButtonPush()
  end

  def goGreen(engine)
    @state = "GREEN"
    @lastTransition = engine.time
    engine.allowDrive()
  end

end




class Runner
  def initialize(time,seed, pedarrival, autoarrival, pedrate, autorate, trace)
    @engine = Engine.new(time,seed, pedarrival, autoarrival, pedrate, autorate, trace)
    #@engine.addEvent(CarSpawn.new(),0)
    @engine.addEvent(PedSpawn.new(@engine.pedSpeed.getVal(@engine.rand,$PEDSPEED)),
                     @engine.pedArrive.nextArrival(@engine.time/60, @engine.rand, $PEDARRIVE)*60
                     )
    @engine.addEvent(LogEvent.new(),0)
    @engine.addEvent(CarSpawn.new(@engine.carSpeed.getVal(@engine.rand,$CARSPEED),
      @engine.rand.uniform(7,12),nil,false),
                    @engine.carArrive.nextArrival(@engine.time/60, @engine.rand, $CARARRIVE)*60,
                    )
    @engine.addEvent(CarSpawn.new(@engine.carSpeed.getVal(@engine.rand,$CARSPEED),
      @engine.rand.uniform(7,12),nil,true),
                    @engine.carArrive.nextArrival(@engine.time/60, @engine.rand, $CARARRIVE)*60,
                    )
   
  end
  def run
    while @engine.moreEvents do
      @engine.apply(@engine.nextEvent)
    end
=begin
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
=end
  end
end

a= Runner.new(ARGV[1].to_i*60,ARGV[2].to_i,ARGV[3],ARGV[4],ARGV[5],ARGV[6],ARGV[7] )
a.run
