require "./sim.rb"

class Ped
  attr_reader :speed, :x, :y
  
  def initialize(speed, startTime)
    @speed = speed
    @x = $PEDSTARTX
    @y = $PEDSTARTY
    @moveLeft = true
    @lastEvent = startTime
  end

  def getPos(time)
    if @moveLeft then
      return [(@x - (time-@lastEvent)* speed).round,@y.round]
    else 
      return [@x.round, (@y + (time-@lastEvent) * speed).round]
    end
  end 

end
