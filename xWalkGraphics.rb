require 'gosu'
require_relative 'logParser'
#require_relative "ContSim"
#sim = Sim.new
#log = sim.run#log is an array of a list of objects in the sim and their positions
#simLog = File.new("simLog.dat")

class XWalkDisplay < Gosu::Window
	def initialize(sim=nil)
		@log = LogParser.new('simLog.dat')
		@simWidth = 10
		@simHeight = 1
		@winWidth = 1000.0
		@winHeight = 500.0
		@sim = sim
		@roadColor = Gosu::Color.argb(0x66666666)
		super(1000,500,false)
		@i = 0
		@pedImage = Gosu::Image.new(self,'man.bmp')
		@carImage = Gosu::Image.new(self,'car.bmp')
		@lightRed = Gosu::Image.new(self,'red.bmp')
		@lightYellow = Gosu::Image.new(self,'yellow.bmp')
		@lightGreen = Gosu::Image.new(self,'green.bmp')

		#@pedImage = Gosu::Image.new(self,'man.bmp')
	end
	def update
		@i += 1
	end
	def needs_redraw?
		return @i < 3
	end
	def draw
		#@tempCol = Gosu::Color.argb(0xff00ff00)
		#draw_quad(0,0,@tempCol ,100,0,@tempCol ,0,100,@tempCol ,100,100,@tempCol )
		drawBackground
		drawList(@log.pedPos[@i],@pedImage)
		drawList(@log.carPos[@i],@carImage)

		#drawRoads
		#drawBlocks
		#drawXWalk
		#drawList()
		#@pedImage.draw(0,0,0)
		#for agent in log[i]
		#end
	end
	def drawBackground(color = Gosu::Color.argb(0xffffffff))
		draw_quad(0,0,color,@winWidth,0,color,0,@winHeight,color,@winWidth,@winHeight,color,0,:default)
	end
	def drawRoads
		drawRoad(@winHeight/2.0,true,50)
		#drawRoad(@winWidth/2.0,false,50)
		7.times{

		}
	end

	def drawRoad(pos,ew,width,color = @roadColor)
		if ew
			draw_quad(0, pos, color, @winWidth, pos, color,0, pos+width, color, @winWidth, pos+width, color,2,:default)
		else
			draw_quad(pos,0,color,pos,@winHeight,color,pos+width,0,color,pos+width,@winHeight,color,2,:default)
		end
	end
	def drawBlocks

	end
	def drawXWalk

	end
	def drawList(list,image)
		for agent in list
			x = agent.x
			y = agent.y
			drawX = x.to_f*20#/@simWidth*@winWidth
			drawY = y.to_f*20#/@simHeight*@winHeight
			image.draw(drawX,drawY,1)
		end
	end
end
disp = XWalkDisplay.new.show