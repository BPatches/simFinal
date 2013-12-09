#require "./sim.rb"

class Ped
  attr_reader :speed, :minEnd
  attr_accessor :x, :y
  
  def initialize(speed, startTime)
    @speed = speed
    @x = $PEDSTARTX
    @y = $PEDSTARTY
    @moveLeft = true
    @lastEvent = startTime
    @minEnd = startTime + $TOTALWALK / speed
    @move = true
  end

  def movingDown(time)
    @moveLeft =false
    @lastEvent = time
    @move = true
  end
  def moving(time,move)
    @move = move
    @lastEvent = time
  end
  def getPos(time)
    if @move then
      if @moveLeft then
        return [(@x - (time-@lastEvent)* speed).round,@y.round]
      else 
        return [@x.round, (@y + (time-@lastEvent) * speed).round]
      end
    else
      return [@x,@y]
    end
  end
end
