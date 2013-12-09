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

class PedSpawn < Event
  def initialize(speed)
    puts "Ped speed #{speed}"
    @speed = speed
  end

  def apply(engine)
    thisPed = Ped.new(@speed,engine.time)
    engine.addAgent(thisPed)
    engine.addEvent(
                    PedSpawn.new(engine.pedSpeed.getVal(engine.rand,$PEDSPEED)),
                    engine.pedArrive.nextArrival(engine.time/60, engine.rand, $PEDARRIVE)*60
                    )
    puts " it is now #{engine.time} this pedestrian will arive at #{engine.time + ($BLOCKWIDTH / (2.0 * @speed))}"
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

class ButtonPush < Event
  def apply(engine)
    engine.pushButton
  end
end

class LogEvent < Event
  def apply(engine) 
    engine.addEvent(LogEvent.new(),engine.time + 1)
    carLog = []
    pedLog = []
    for agent in engine.agents
#      if agent.class == Car
#        carLog.push(agent.getPos(engine.time))
#      else 
        pedLog.push(agent.getPos(engine.time))
#      end
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
