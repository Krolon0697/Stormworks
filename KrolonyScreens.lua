---@diagnostic disable:unbalanced-assignments

---@section Screens 1 DRAWCLASS
Krolony.Screens={
	---@section createButton
	---creates an object to be used as a button
	---@param x number position of upper left corner
	---@param y number position of upper left corner
	---@param w number width, can be left as 0 to make it match the length of text
	---@param h number height
	---@param onRGBA table color when state is true {red,green,blue,alpha}
	---@param offRGBA table color when state is true {red,green,blue,alpha}
	---@param mode string to denote how it works, 'pulse' 'hold' or 'toggle'
	---@param txt string to be drew
	---@param drawTxt boolean flag whether to draw text or not
	---@return table
	createButton=function(x,y,w,h,onRGBA,offRGBA,mode,txt,drawTxt)
		return {
			x=x,
			y=y,
			w=w==0 and #txt*5+2 or w,
			h=h==0 and 8 or h,
			onRGBA=onRGBA,
			offRGBA=offRGBA,
			mode=mode,
			active=true,
			txt=txt,
			drawTxt=drawTxt,
			state=false,
			timer=0,
			---use in onTick to manage the states
			---@param self table
			---@param x number touchX
			---@param y number touchY
			---@param press boolean isTouched
			manage=function(self,x,y,press)
				local hold=x>=self.x and x<=self.x+self.w and y>=self.y and y<=self.y+self.h and press and self.active
				self.timer=hold and self.timer+1 or 0
				self.state=self.mode=='pulse' and self.timer==1 or self.mode=='hold' and self.timer>0 or self.mode=='toggle' and self.state
				if self.mode=='toggle' and self.timer==1 then self.state=not self.state end
			end,
			---if is active then it draws the button according to the data inside of button
			---@param self table
			draw=function(self)
				if self.active then
					screen.setColor(table.unpack(self.state and self.onRGBA or self.offRGBA))
					screen.drawRect(self.x,self.y,self.w,self.h)
					if self.drawTxt then screen.drawText(self.x+2,self.y+2,self.txt) end
				end
			end
		}
	end,

	---@section drawPolygon
	---draws lines from vertice to vertice
	---@param polygon table order matters, table {{x,y},{x,y}...}
	drawPolygon=function(polygon)
		for i=0,#polygon-1 do
			local current,next=polygon[(i%#polygon)+1],polygon[((i+1)%#polygon)+1]
			screen.drawLine(current[1],current[2],next[1],next[2])
		end
	end,
	---@endsection

	---@section drawTriangulatedPolygonF
	---draws triangles that are outputted by triangulatePolygon
	---@param triangles table { { {x,y},{x,y},{x,y} } , {...} , ...}
	drawTriangulatedPolygonF=function(triangles)
		for i,triangle in ipairs(triangles) do
			screen.drawTriangleF(triangle[1][1],triangle[1][2],triangle[2][1],triangle[2][2],triangle[3][1],triangle[3][2])
		end
	end,
	---@endsection

	---@section drawPixelArt
	---draws pixels art, encoding it however is a little troublesome, pixels are encoded into numbers
	---@param x number upper left corner
	---@param y number upper left corner
	---@param art table {line,line,line}, whole lines are encoded binarily into a single integer
	drawPixelArt=function(x,y,art)
		for i=1,#art do
			local temp,exp=art[i]
			while temp>0 do
				exp=math.log(temp,2)//1
				temp=temp-2^exp
				screen.drawLine(x+exp,y+i-1,x+exp+1,y+i-1)
			end
		end
	end,
	---@endsection

	---@section drawTextWrapped
	---my own take at wrapping text within some width
	---@param x number upper left corner of drawing
	---@param y number upper left corner of drawing
	---@param width number how many pixels there are
	---@param txt string
	drawTextWrapped=function(x,y,width,txt)
		local txt,dx,length,temp,notfirst=txt..' ',x
		repeat
			length=txt:find(' ') or #txt
			if dx+length*5-6>x+width and notfirst then
				dx=x
				y=y+6
				notfirst=false
			end
			notfirst=true
			temp=txt:sub(1,length)
			txt=txt:sub(length+1)
			screen.drawText(dx,y,temp)
			dx=dx+length*5
		until #txt==0
	end,
	---@endsection


	---@section HSV
	---changes HSV into RGB and corrects it's gamma for the filfthy SW displays
	---@param h number hue  0-359 (360 wraps)
	---@param s number saturation 0-1
	---@param v number value 0-1
	---@param alpha number alpha 0-1
	---@return number red 0-255
	---@return number green 0-255
	---@return number blue 0-255
	---@return number alpha 0-255
	HSV=function(h,s,v,alpha)
		local alpha,c,i,d,x,m=alpha or 1,v*s,math.floor((h%360)/60)+1
		x,m=c*(1-math.abs((h/60)%2-1)),v-c
		d={{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}}
		return Krolony.Screens.correctRGBA((d[i][1]+m)*255,(d[i][2]+m)*255,(d[i][3]+m)*255,alpha*255)
	end,
	---@endsection

	---@section correctRGBA
	---correct for filthy SW displays, range 0-255, returns r,g,b,a
	---@param r number
	---@param g number
	---@param b number
	---@param a number
	---@return number red
	---@return number green
	---@return number blue
	---@return number alpha
	correctRGBA=function(r,g,b,a)
		local gamma,k=2.4,0.85
		return 255*(k*r/255)^gamma,255*(k*g/255)^gamma,255*(k*b/255)^gamma,255*(k*a/255)^gamma
	end,
	---@endsection

	---@section makeDial
	makeDial=function(center_x,center_y,width,height,orientation_angle,arc_segments,arc_radians,antiAliasing,r,g,b)
		return {
			marks={},
			arrows={},
			antiAliasing=antiAliasing,
			center_x=center_x,
			center_y=center_y,
			width=width,
			height=height,
			orientation_angle=orientation_angle,
			arc_radians=arc_radians,
			arc_segments=arc_segments,
			r=r,
			g=g,
			b=b,
			insertMark=function(self,inside,outside,amount,r,g,b)
				table.insert(self.marks,{inside=inside,outside=outside,amount=amount,r=r,g=g,b=b})
			end,
			insertArrow=function(self,arrowID,length,width,r,g,b)
				self.arrows[arrowID]={length=length,width=width,r=r,g=g,b=b,pos=0}
			end,
			update=function(self,arrowID,value)
				self.arrows[arrowID].pos=value
			end,
			draw=function(self)
				local cos,sin,color,line,triangle=math.cos,math.sin,screen.setColor,screen.drawLine,screen.drawTriangleF
				local cx,cy,rot,w,h,findPos,alpha,aliasing,x,y,xl,yl,thickness,length_correct,helper=self.center_x,self.center_y,self.orientation_angle
				findPos=function(angle)
					local cr,sr,ca,sa=cos(rot),sin(rot),cos(angle),sin(angle)
					return cx+cr*w*sa+sr*h*ca,cy+sr*w*sa-cr*h*ca
				end

				thickness=(self.width+self.height)/2
				thickness=math.atan(1,thickness)
				length_correct=self.width/self.height
				for alias=antiAliasing,0,-1 do
					alpha=alias==0 and 1 or 1-math.abs(alias/antiAliasing)
					alpha=255*alpha^2.4
					color(self.r,self.g,self.b,alpha)
					aliasing=alias==0 and 0 or 1.5*(-1)^alias*alias/antiAliasing--secures against 0/0 when no AA
					w,h=self.width+aliasing,self.height+aliasing
					xl,yl=findPos(-self.arc_radians/2)
					for i=1,self.arc_segments do
						x,y=findPos(i/self.arc_segments*self.arc_radians-self.arc_radians/2)
						line(x,y,xl,yl)
						xl,yl=x,y
					end

					aliasing=alias==0 and 0 or 1.5*alias/antiAliasing --secures against 0/0 when no AA
					for index,mark in ipairs(self.marks) do
						color(mark.r,mark.g,mark.b,alpha)
						for i=0,mark.amount-1 do
							i=i/(mark.amount-1)*self.arc_radians-self.arc_radians/2+thickness*aliasing*(-1)^alias
							helper=aliasing^2+mark.inside
							w=self.width-helper
							h=self.height-helper
							x,y=findPos(i)
							helper=aliasing^2+mark.outside
							w=self.width+helper
							h=self.height+helper
							xl,yl=findPos(i)
							line(x,y,xl,yl)
						end
					end
					for index,arrow in ipairs(self.arrows) do
						color(arrow.r,arrow.g,arrow.b,alpha)
						--w=arrow.length*self.width/self.height+aliasing*2
						helper=self.arc_radians*(arrow.pos-0.5)
						h=arrow.length+aliasing*2
						w=h*length_correct
						x,y=findPos(helper)
						w=arrow.width+aliasing*2
						h=w
						xl,yl=findPos(helper+1.57)
						triangle(x,y,xl,yl,2*cx-xl,2*cy-yl)
						x,y=findPos(helper+3.14)
						triangle(x,y,xl,yl,2*cx-xl,2*cy-yl)
					end
				end
			end
		}
	end
	---@endsection
	}
---@endsection DRAWCLASS
---@diagnostic enable:unbalanced-assignments