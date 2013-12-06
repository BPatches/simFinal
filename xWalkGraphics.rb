require 'gosu'
#require_relative "ContSim"
#sim = Sim.new
#log = sim.run#log is an array of a list of objects in the sim and their positions

class XWalkDisplay < Gosu::Window
	def initialize
		super(500,500,false)
		@i = 0
		@pedImage = Gosu::Image.new(self,'man.bmp')
		#@pedImage = Gosu::Image.new(self,'man.bmp')
	end
	def update
		@i += 1
	end
	def draw
		@pedImage.draw(0,0,0)
		#for agent in log[i]

		#end
	end
end
disp = XWalkDisplay.new.show
