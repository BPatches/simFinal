
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

class PedSpawn
  def initialize(speed)
    @speed = speed
  end

  def apply(engine)
    thisPed = Ped.new(@speed,engine.time)
    engine.addAgent(thisPed)
    engine.addEvent(
                    PedSpawn.new(engine.pedSpeed.getVal(engine.rand,$PEDSPEED)),
                    engine.pedArrive.nextArrival(engine.time, engine.rand, $PEDARRIVE)
                    )
    engine.addEvent(PedArrive.new(thisPed))
  end
end


class PedArrive
  def initialize(ped)
    @thisPed = ped
  end
  def apply(engine)
    @thisPed.x = $XWALKLOC
    @thisPed.movingDown(engine.time)
    if engine.isWalk and engine.walkEnd - $XWALKLENGH/@thisPed.speed > 0 then
      engine.addEvent(PedDone.new(@thisPed),engine.time + $XWALKLENGH/@thisPed.speed)
    else
      engine.tryPushButton()
      engine.addWaitingPed(@thisPed)
    end
  end
end

class PedDone
  def initalize(ped)
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
    carLog = []
    pedLog = []
    for agent in engine.agents
      if agent.class == Car
        carLog.push(agent.getPos(engine.time))
      else 
        pedLog.push(agent.getPos(engine.time))
      end
    end
    File.open(engine.logFile,a) do |log|
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
