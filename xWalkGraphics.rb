require 'gosu'
require './logParser'
#require_relative "ContSim"
#sim = Sim.new
#log = sim.run#log is an array of a list of objects in the sim and their positions
#simLog = File.new("simLog.dat")

class XWalkDisplay < Gosu::Window
  def initialize(inF)
    @log = LogParser.new(inF)
    @simWidth = 330*7
    @simHeight = 46+10
    @winWidth = 1024
    @edge = 64
    @winHeight = (@winWidth*@simHeight.to_f/@simWidth).round

    @fps = 10
    @roadColor = Gosu::Color.argb(0x66666666)
    super(@winWidth,@winHeight+2*@edge,false,1000.0/@fps)
    @timeWarp = 1
    @pedImage = Gosu::Image.new(self,'images/man.bmp')
    @carImage = Gosu::Image.new(self,'images/car.bmp')
    @backgroundImage = Gosu::Image.new(self,'images/simFinal.bmp')
    @lightPosX = @winWidth/2.0-64
    @lightPosY = 0
    @lightRed = Gosu::Image.new(self,'images/red.bmp')
    @lightYellow = Gosu::Image.new(self,'images/yellow.bmp')
    @lightGreen = Gosu::Image.new(self,'images/green.bmp')
    #	@backgroundImage.draw(0,@edge,0)
  end
  def update
    @timeWarp.times{
      @log.advance
    }
  end
  def button_down(id)
  	case id
  	when 52
  		@timeWarp += 1
  	when 51
  		if @timeWarp > 1
  			@timeWarp -= 1
  		end
  	end
  		
  end
  #	def needs_redraw?
  #		return @i < 3
  #	end
  def draw
    #@tempCol = Gosu::Color.argb(0xff00ff00)
    #draw_quad(0,0,@tempCol ,100,0,@tempCol ,0,100,@tempCol ,100,100,@tempCol )
    drawBackground
    drawBackgroundImage
    #@backgroundImage.draw(0,@edge,0)
    drawList(@log.pedPos,@pedImage)
    drawList(@log.carPos,@carImage,false)
    case @log.lightState
    when "GREEN"
      @lightGreen.draw(@lightPosX,@lightPosY,1)
    when "YELLOW"
      @lightYellow.draw(@lightPosX,@lightPosY,1)
    when "RED"
      @lightRed.draw(@lightPosX,@lightPosY,1)
    else
    	close
    end
  end
  def drawBackgroundImage
    scale = @winWidth/@backgroundImage.width.to_f
    @backgroundImage.draw(0,@edge,0,scale,scale)
  end

  def drawBackground(color = Gosu::Color.argb(0xffffffff))
    draw_quad(0,0,color,@winWidth,0,color,0,@winHeight+2*@edge,color,@winWidth,@winHeight+2*@edge,color,0,:default)
  end
  def drawList(list,image,ped = true)
    for agent in list
      x = agent.x
      y = agent.y
      drawX = x.to_f/@simWidth*@winWidth
      drawY = y.to_f/@simHeight*@winHeight+@edge
      if ped
      	drawX -= image.width/2.0*0.3
        drawY -= (image.height)
      end
      image.draw(drawX,drawY,1,0.3)
    end
  end
end
disp = XWalkDisplay.new(ARGV[0]).show
