require_relative "LRandom"
require_relative "Welford"

module LightState
  Green = 0
  Yellow = 1
  Red =2
  def changeLight(lightState)
  	case lightState
  	when Green
  		return Yellow
  	when Yellow
  		return Red
  	when Red
  		return Green
  	end
  end
  def toString(lightState)
  	case Green
  		return 'green'
  	case Yellow
  		return 'yellow'
  	case Red
  		return 'red'
  	end
  end
end
class Event
	attr_reader :time
	attr_accessor :sim
	def initialize(time)
		@time = time
		@sim = nil
	end
	def happen
		puts "this event does nothing"
		return nil
	end
end
class ButtonPressEvent < Event
	def happen
		return LightChangeEvent.new(@time+1)
	end
end
class LightChangeEvent < Event
	def happen
		@sim.lightState = LightState::changeLight(@sim.lightState)
		if @sim.lightState == LightState::Yellow
			return LightChangeEvent(@time + 8)
		elsif @sim.lightState == LightState::Red
			return LightChangeEvent(@time + 12)
		else
			return nil
		end			
	end
end
class PedSpawn < Event
	def happen
		@sim.agents.push(Pedestrian.new)
		return PedSpawn.new(@sim.randGen.exponential(0.25/2.0*60)+@time)
	end
end
class CarSpawn < Event
	def happen
		@sim.agents.push(Car.new)
		return CarSpawn.new(@sim.randGen.exponential(0.25/2.0*60)+@time)
	end
end
class NextEventQueue
	def initialize(sim,maxTime)
		@maxTime = maxTime
		@sim = sim
		@queue = []
	end
	def nextEvent
		return @queue.last
	end
	def nextEventHappen
		relatedEvent = @queue.pop.happen
		if relatedEvent != nil
			enqueue(relatedEvent)
		end
	end
	def enqueue(event)
		event.sim = @sim
		if event.time < @sim.time
			puts "event should already have happened"
			return
		end
		if event.class == CarSpawn || event.class == PedSpawn
			if event.time > @maxTime
				return
			end
		end
		@queue.push(event)
		@queue.sort_by{ |x|
			-x.time
		}
	end

	def nextLightChange
		return @queue.find_all{ |x|	x.class == LightChangeEvent	}.last.time
	end

	def state
		for event in queue
			puts "#{event.time} #{event.class}"
		end
	end
end
class ExitEvent < Event
	def happen
		#gather statistics
	end
end
class LogEvent < Event
	def happen 
		carLog = []
		pedLog = []
		for agent in @sim.agent
			if agent.class == Car
				carLog.push([agent.x.round,agent.y.round])
			else 
				pedLog.push([agent.x.round,agent.y.round])
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
class Sim
	attr_reader :time,:randGen, :blockWidth, :nextEventQueue, :crossWalkDistance,:carTravelDistance
	attr_accessor :lightState,:agents
	def initialize(maxTime=30,seed=1)
		@maxTime = maxTime*60
		@randGen = LRandom.new(seed)
		@time = 0
		@agents = []
		@lightState = LightState::Green
		@nextEventQueue = NextEventQueue.new(self,@maxTime)
		#-----------------------------------------
		@blockWidth=330
		@crossWalkDistance = 46
		@crossingWalkWidth = 22
		@carTravelDistance = 7*@blockWidth-@crossingWalkWidth
		#-----------------------------------------
		@nextEventQueue.enqueue(PedSpawn.new(0))
		#@nextEventQueue.enqueue(CarSpawn)
		@agents.clear
	end
end

class Agent
	attr_accessor :x,:y
	def initialize(sim,x=0,y=0)
		@x = x
		@y = y
		@sim = sim
		@pos = Pos.new
	end
end
class Pedestrian < Agent
	def initialize(sim)
		super(sim)
		@pos.x = @sim.carTravelDistance-@sim.blockWidth/2.0
		@timeWaiting = 0
		@speed = @sim.randGen.uniform(6,13)
		@crossing = false
	end
	def act
		if !atButton
			walk
		elsif arrivedAtButton
			pressButton
		else 
			wait
		end
	end
	def atButton
		return pos == @sim.buttonPos
	end
	def arrivedAtButton
		return atButton && @timeWaiting == 0
	end
	def walk
		@pos += @speed*@sim.timeStep
		if (@pos-@sim.buttonPos).abs <= (@speed*@sim.timeStep).abs
			@pos = @sim.buttonPos
			@sim.pedsWaiting += 1
		end
	end
	def pressButton(tiredOfWaiting = false)
		decidedToPressButton = tiredOfWaiting
		if @sim.pedsWaiting == 1
			if @sim.randGen.uniform(0,3) <= 2
				decidedToPressButton = true
			end
		else
			if @sim.randGen.uniform(0,@sim.pedsWaiting) <= 1 
				decidedToPressButton = true
			end
		end
		if decidedToPressButton
			@sim.nextEventQueue.enqueue(ButtonPressEvent.new(@sim.time))
		end
	end 
	def wait
		if @sim.lightState == LightState::Red
			if cross
				return
			end
		end
		@timeWaiting += @sim.timeStep
	end
	def cross
		if 	@sim.nextEventQueue.nextLightChange-@sim.time > @sim.crossWalkDistance/@speed.to_f
			@crossing = true
			@sim.nextEventQueue.enqueue(pedExitEvent.new(@time + @sim.crossWalkDistance/@speed.to_f))
			return true
		end
	end
end
