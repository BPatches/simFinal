
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

class PedArrive
  def initialize(speed)
    @ped = 








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
    File.open("simLog.dat",a) do |log|
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
      log.syswrite('green')
      log.syswrite('}')
      log.puts
    end
  end
end
