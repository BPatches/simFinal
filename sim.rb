require "./LRandom.rb"
require "./Welford.rb"
require "./distributions.rb"


$BLOCKWIDTH = 330
$PEDSTARTX = $BLOCKWIDTH*4 
$PEDSTARTY = 0
$XWALKLOC = $BLOCKWIDTH*3.5
$XWALKLENGTH = 46
$TOTALWALK = $BLOCKWIDTH/2 + @XWALKLENGH
$TOTALWALK = 
$PEDSPEED = 0
$PEDARRIVE = 1


class Engine
  attr_reader :agents , :rand, :pedArrive, :pedSpeed,:pedWill,:signal,:logFile
  def initialize(endTime,seed,pedArriveF,carArriveF,
                 pedSpeedF,carSpeedF,logFile)
    @pedWaiting = []
    @agents = []
    @signal = Light.new()
    @rand = LRandom.new(seed,5)
    @pedWil = Welford.new(20)
    @carWil = Welford.new(20)
    @carArrive = Lambda.new(carArriveF)
    @pedArrive = Lambda.new(pedArriveF)
    @pedSpeed = CustDistr.new(pedSpeedF)
    @carSpeed = CustDistr.new(carSpeedF)
    @time = 0
    @finalTime = endTime
    @eventsList = Array.new
    @logFile = logFile
  end
  
  def addAgent(agent)
    @agents << agent
  end

  def addWaitingPed(ped)
    @pedWaiting << ped
  end

  def tryPushButton
    if @pedWaiting.length == 0 then
      if @rand.uniform(0,1,engine.pedPush) < 2.0/3.0 then
        pushButton()
      end
    else
      if @rand.uniform(0,1,engine.pedPush) < 1.0/@pedWaiting.length then
        pushButton()
      end
    end
    @addEvent(ButtonPush.new(),engine.time + 60)
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

  def addEvent(newEvent,time)
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
      add( PedDone.new(ped),@time + $WALKLENGH/ped.speed)
      ped = @pedWaiting.shift
    end
  end

  def apply(event)
    @time = event.time
    event.apply(self)
  end

  def removeAgent(agent)
    @agents.delete(agent)
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




class Runner
  def initialize(time,seed, pedarrival, autoarrival, pedrate, autorate, trace)
    @engine = SimEngine.new(time,seed, pedarrival, autoarrival, pedrate, autorate, trace))
    @engine.add(CarSpawn.new(),0)
    #@engine.add(PedSpawn.new(),0)
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
=begin
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
