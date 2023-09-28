---@diagnostic disable:unbalanced-assignments
---@section Specialized 1 SPECIALCLASS
Krolony.Specialized={

	---@section bitWork 1 BITCLASS
	bitWork={
		---@section floatToBits
		---Converts X into an integer of same bit representation.
		---IEEE754 compliant
		---@param x number float
		---@param exponentBits integer amount of exponent bits, 1 bit for sign
		---@param mantissaBits integer amount of mantissa bits
		---@return integer exponent
		---@return integer mantissa
		floatToBits=function(x,exponentBits,mantissaBits)
			local sign,mantissa,exponent,precision,check
			exponentBits=exponentBits-1
			if x~=x then return 2^exponentBits-1,1 end --NaN
			sign=x<0 and 2^exponentBits or 0
			mantissa=math.abs(x)
			--if mantissa<=2^(-2^(exponentBits-1)+1) then return 0,0 end --0 and no subnormals
			--if mantissa==0 then return 0,0 end --assign 0, don't touch subnormals
			if mantissa>=2^(2^(exponentBits-1)) then return sign+2^exponentBits-1,0 end --assign infinities
			precision=math.log(mantissa,2)//1
			check=mantissa/2^precision
			precision=math.max(-2^(exponentBits-1)+1,precision+(check<1 and -1 or check>=2 and 1 or 0)) --correct for inaccurate log :rolling_eyes:
			--max because subnormals, and we don't want exponent lower than 0
			exponent=math.min(2^exponentBits-1,2^(exponentBits-1)-1+precision)
			mantissa=(mantissa / 2^precision - (exponent==0 and 0 or 1))*2^mantissaBits

			return sign+exponent,(mantissa+0.5)//1
		end,
		---@endsection

		---@section bitsToFloat
		---converts integer back to floating point number
		---@param exponent integer
		---@param mantissa integer
		---@param exponentBits integer
		---@param mantissaBits integer
		---@return number float
		bitsToFloat=function(exponent,mantissa,exponentBits,mantissaBits)
			exponentBits=exponentBits-1
			local sign,check=exponent<2^exponentBits and 1 or -1
			exponent=exponent&(2^exponentBits-1)
			check=exponent==0
			if exponent==2^exponentBits-1 then return (sign*math.max(-mantissa+1,0))/0 end --infinities and nan
			exponent=exponent-2^(exponentBits-1)+1
			--if check0 then return 0 end --0 and  no subnormals
			return sign*2^exponent*((check and 0 or 1)+mantissa/2^mantissaBits)
		end,
		---@endsection

		---@section floatToBitsDry
		---Converts X into an integer of same bit representation.
		---not IEEE754 compliant - supports ONLY normal floating point numbers. No infinities, NaNs or subnormals
		---@param x number float
		---@param exponentBits integer amount of exponent bits, 1 bit for sign
		---@param mantissaBits integer amount of mantissa bits
		---@return integer exponent
		---@return integer mantissa
		floatToBitsDry=function(x,exponentBits,mantissaBits)
			exponentBits=exponentBits-1
			local sign,mantissa,exponent,precision,check
			sign=x<0 and 2^exponentBits or 0
			mantissa=math.abs(x)
			if mantissa<=2^(-2^(exponentBits-1)+1) then return 0,0 end --0 and no subnormals
			precision=math.log(mantissa,2)//1
			check=mantissa/2^precision
			precision=precision+(check<1 and -1 or check>=2 and 1 or 0) --correct for inaccurate log :rolling_eyes:
			exponent=math.min(2^exponentBits-1,2^(exponentBits-1)-1+precision)
			mantissa=((mantissa/2^precision-1)*2^mantissaBits+0.5)//1

			return sign+exponent,(mantissa+0.5)//1
		end,
		---@endsection

		---@section bitsToFloatDry
		---converts integer back to floating point number
		---@param exponent integer
		---@param mantissa integer
		---@param exponentBits integer
		---@param mantissaBits integer
		---@return number float
		bitsToFloatDry=function(exponent,mantissa,exponentBits,mantissaBits)
			exponentBits=exponentBits-1
			if exponent==0 then return 0 end
			local sign=exponent<2^exponentBits and 1 or -1
			exponent=(exponent&(2^exponentBits-1))-2^(exponentBits-1)+1
			return sign*2^exponent*(1+mantissa/2^mantissaBits)
		end
		---@endsection
	},
	---@endsection BITCLASS

	---@section encode
	---encodes a number into a string
	---@param toCode number
	---@param coder string a coding string with only unique characters, don't make anything repeat
	---@param length integer length of resulting output
	---@param zeroToOneRange boolean flag to specify whether it's working on a floating point in 0-1 range or integer
	---@return string coded output
	encode=function (toCode,coder,length,zeroToOneRange)
		local t,b,coderLen,coded,a={},'',coder:len()
		coded=zeroToOneRange and (toCode*(coderLen^length-1))//1 or toCode
		for i=1,length do
			a=(coderLen^(length-i))
			table.insert(t,coded//a)
			coded=coded-(coded//a)*a
		end
		for i,v in ipairs(t) do
			b=b..coder:sub(v+1,v+1)
		end
		return b
	end,
	---@endsection

	--[[
	chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	--powyżej są bez znaków, poniżej 1 - wszystkie chars 2 - bez \ bo niebezpieczne 3 bez ciężko czytelnych 4 dla idiotów
	chars='!"#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
	chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&()*+,-./:;<=>?@[]^_`{|}~'
	chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!&()+-./<=>?[]^`{}~'
	chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!+-./<=>?[^`{}'
	]]
	---@section decode
	---decode a string back into a number or integer
	---@param todecode string
	---@param coder string
	---@param zeroToOneRange boolean
	---@return number decoded
	decode=function(todecode,coder,zeroToOneRange)
		local coderLen,length,a,v=coder:len(),todecode:len(),0
		for i=1,length do
			v=coder:find(todecode:sub(i,i),1,true)-1
			a=a+v*coderLen^(length-i)
		end
		return zeroToOneRange and a/(coderLen^length-1) or a
	end,
	---@endsection

	---@section fitPoly
	---very resource expensive, the more data you have the worse it is, but it does a decent fit, progressively gets better, parabolas are order 2, data table {{x,y},{x,y}} that you want to fit, speed how many paths it checks per call, provide with memory table, returns table of a polynomial {a0,a1,a2}
	---@param amtOfCoefs integer how many coefficient it has to work with
	---@param data table {{x,y},{x,y},...} data to fit to
	---@param errorFunction function function(coefficients,data) that outputs the error between data and a function with given coefficients
	---@param speed integer how many iterations it does per call
	---@param memorytable table feed it empty unique table which it's gonna use as it's memory
	---@return table coefficients
	fitPoly=function(amtOfCoefs,data,errorFunction,speed,memorytable)
		local coefsCheck,mem,rnd,possibilities,checked,step,errSaved,errCheck,k,coefsSaved={},memorytable,math.random
		if #mem~=6 or #mem[4]~=amtOfCoefs then
			for i=1,6 do
				mem[i]=1
			end
			mem[4]={}
			for i=1,amtOfCoefs do
				mem[4][i]=0
			end
		end
		--step,err1,b,k,m=mem[2],mem[3],mem[4],mem[5],mem[6]
		step,errSaved,coefsSaved,k,checked=mem[2],errorFunction(mem[4],data),mem[4],mem[5],mem[6]
		--err1=errorFunction(b,data)
		possibilities=3^amtOfCoefs
		for i=1,speed do
			checked=checked+1
			if checked>possibilities then step,checked=step*rnd(),1 end
			k=k+1
			for j=1,amtOfCoefs do
				coefsCheck[j]=coefsSaved[j]+step*(k//3^(j-1)%3-1)*rnd()
			end
			errCheck=errorFunction(coefsCheck,data)
			if errCheck<errSaved then
				errSaved=errCheck
				k=k-1
				for i=1,amtOfCoefs do
					coefsSaved[i]=coefsCheck[i]
				end
				step=step*1.1
				mem[1]=mem[1]+1
				checked=0
			end
		end
		mem[2]=step>0 and step or 1
		mem[3]=errSaved
		mem[5]=k
		mem[6]=checked
		return coefsSaved
	end,
	---@endsection

	---@section Dial

	---draws a dial, arc in degrees, aspect is height/width (circle/elipse), rotation offset, reverse is bool to change direction, aliasting is a number
	Dial=function(cenx,ceny,radius,minvalue,maxvalue,value,marks,arc,aspect,rotation,reversed,aliasing,H,S,V)
		local rot,x,y,d,x1,y1,x2,y2,an,r,g,b,a=rotation,cenx,ceny,arc,1/(maxvalue-minvalue)
		local findPos=function(x,y,radius,angle)
			local r1,r2=radius/math.max(1,aspect),radius/math.max(1,1/aspect)
			return x+math.cos(rot)*r1*math.cos(angle)-math.sin(rot)*r2*math.sin(angle),y+math.sin(rot)*r1*math.cos(angle)+math.cos(rot)*r2*math.sin(angle)
		end

		y1=-x1*minvalue
		x1=value*x1+y1
		d=d*pi/180
		an=d*(x1-1/2)*(reversed and -1 or 1)
		rot=(rot+90)*pi/180
		--r,g,b=HSV(H,S,V,2.2)
		for j=1,aliasing do
			r0=radius+2*j/aliasing-1
			x2,y2=findPos(x,y,r0,-d/2-pi)
			r,g,b,a=Krolony.Draw.HSV(H,S,V,-255*math.abs(2*j/aliasing-1)+255)
			--sC(r,g,b,-255*abs(2*j/aliasing-1)+255)
			screen.setColor(r,g,b,a)
			for i=-marks,marks do
				x1,y1=findPos(x,y,r0,d*i/marks/2-pi)
				screen.drawLine(x1,y1,x2,y2)
				x2,y2=x1,y1
			end
			for i=-marks,marks,2 do
				x1,y1=findPos(x,y,r0+2,d*i/marks/2-pi)
				x2,y2=findPos(x,y,r0-3,d*i/marks/2-pi)
				screen.drawLine(x1,y1,x2,y2)
			end
			x1,y1={},{}
			x1[1],y1[1]=findPos(x,y,r0-5,an+pi)
			for i=-1,1 do
				x1[i+3],y1[i+3]=findPos(x,y,r0/(3+math.abs(i)),an+pi*(2+i/2))
			end
			for i=1,4 do
				screen.drawLine(x1[i],y1[i],x1[i%4+1],y1[i%4+1])
			end
		end
	end,
	---@endsection

	---@section Ballistics2D

	---optimized physics simulation to eyeball the required elevation, no speed correction nor leading, elev in radians, velocity of gun in m/s, lifetime in ticks, drag as posted by devs, indirect fire is a bool, returns a radian, can't reach bool and flighttime in ticks
	Ballistics2D=function(x,y,elevation,velocity,drag,lifetime,indirect)
		local x,y,tx,ty,vx,vy=0,0,x,y
		local e,v,d,l,g,step,t,bad=elevation,velocity,1-drag,lifetime,30/3600,1,0

		vx,vy=v*cos(e)/60,v*sin(e)/60
		repeat
			x=x+vx*(1-d^step)/(1-d)
			y=y+vy+d*(d^(step-1)*(-(d*(g-vy)+vy))+d*g*(step-1)+d*g-d*vy-g*(step-1)+vy)/(d-1)^2
			vx=vx*d^step
			vy=vy*d^step-d*g*(d^step-1)/(d-1)

			t=t+step
			step=(tx-x)//vx
			step=step+t>l and (l-t>1 and l-t-1 or 1) or step>1 and step or 1
			--if step<1 then fuckme() end
			bad=t>=l or ((vx*vx+vy*vy)^0.5<5/6 and l<1000)
		until x>tx-vx/2 or bad
		e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or Krolony.Utilities.clamp(-pi/2,pi/2,e+(math.atan(ty/tx)-math.atan(y/x))/(indirect and -200000/tx or 3))
		return e,bad,t,((tx-x)^2+(ty-y)^2)^0.5
	end,
	---@endsection

	---@section Ballistics
	---optimized physical simulation, world relative, has correction for vehicle speed but no built in leading, returns flight time for that, vehicle {{position},{speed}} in m and m/s, {x,y,z}, target {x,y,z}, iteratively adjusts azim and elev in radians world relative 0 for north and level (outputs in same manner, you feed it back in for next iteration), gun {velocity,drag,lifetime}, indirect boolean, returns azimuth, elevation, flighttime in ticks, miss radius in meters (never 0), boolean can't reach
	Ballistics=function(vehicle,target,azim,elev,gun,indirect)
		local a,e,v,t,h,vh,bad=azim,elev,vehicle,target
		local ix,iy,iz,vx,vy,vz=v[1][1],v[1][2],v[1][3],v[2][1],v[2][2],v[2][3]
		local x,y,z=ix,iy,iz
		local tx,ty,tz=t[1],t[2],t[3]
		local v,d,l,g,step=gun[1],1-gun[2],gun[3],30/3600,1
		local th,t=((tx-ix)^2+(ty-iy)^2)^0.5,0
		vx,vy,vz=(vx+v*math.sin(a)*math.cos(e))/60,(vy+v*math.cos(a)*math.cos(e))/60,(vz+v*math.sin(e))/60
		repeat
			x=x+vx*(1-d^step)/(1-d)
			y=y+vy*(1-d^step)/(1-d)
			z=z+vz+d*(d^(step-1)*(-(d*(g-vz)+vz))+d*g*(step-1)+d*g-d*vz-g*(step-1)+vz)/(d-1)^2
			vx=vx*d^step
			vy=vy*d^step
			vz=vz*d^step-d*g*(d^step-1)/(d-1)

			t=t+step
			v,vh=(x-ix),(y-iy)
			h=(v*v+vh*vh)^0.5
			vh=(vx*vx+vy*vy)^0.5
			step=(th-h)//vh
			step=step+t>l and (l-t>1 and l-t-1 or 1) or step>1 and step or 1
			--if step<1 then fuckme() end
			bad=t>=l or ((vh*vh+vz*vz)^0.5<5/6 and l<1000)
		until h>th-vh/2 or bad
		v,d=math.atan(tx-ix,ty-iy),math.atan(x-ix,y-iy) 
		a=((a+v-d)%(2*pi)+3*pi)%(2*pi)-pi
		--e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or min(pi/2,max(-pi/2,e+(atan((tz-iz)/th)-atan((z-iz)/h))/(indirect and -200000/th or 3)))
		--min(pi/2,max(-pi/2,e+(atan((tz-iz)/th)-atan((z-iz)/h))/(indirect and -200000/th or 3)))
		e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or Krolony.Utilities.clamp(-pi/2,pi/2,e+(math.atan((tz-iz)/th)-math.atan((z-iz)/h))/(indirect and -200000/th or 3))
		vx,vy,vz=x-tx,y-ty,z-tz
		v=(vx*vx+vy*vy+vz*vz)^0.5
		return a,e,t,v,bad
		--[[
		requires
		pi,sin,cos,atan,clamp(min,max,value)
		vehicle is {{x,y,z} as location,{x,y,z} as speed}
		target is just {x,y,z}, no inside leading
		azimuth from -pi to pi in world alignment, positive Y is 0, positive X is pi/2, same elev but -pi/2 to pi/2
		gun is {velocity (900 for example),drag (0.005 for example), lifetime}
		indirect - if true, it will go for a high arc fire
		returns : time of shell flight, error between shell and target in meters, corrected azimuth and corrected elevation, out of range boolean,elevlock boolean
		it has issues of it's gun getting stuck vertically up (direct) and vertically down (indirect), that's why elevlock is for
		instead of adding and forcing generic limiters I decided to let it be open to user, because every gun has a different angle transition for a flat target
		and because target really isn't always flat on the ground so... it lets you know when it fucked up so that you can fix it yourself, and thus work in wider range of circumstances 
		]]
	end,
	---@endsection

	---@section createRender
	createRender=function(near_plane,far_plane,cam_fov)
		local vecNew,shadeA,shadeB,shadeC=Krolony.Math.Vec3.newV3
		shadeA,shadeB,shadeC=vecNew(),vecNew(),vecNew()
		return {
			points={},
			points_g={},
			triangles={},
			near_plane=near_plane,
			far_plane=far_plane,
			cam_fov=cam_fov,
			aspect=1,

			shader=function(triangle,vec,points)
				local mid,v0,v1,v2,N=triangle.mid,points[triangle[1]],points[triangle[2]],points[triangle[3]],triangle.normal

				mid:subV3(vec,shadeC)
				v1:subV3(v0,shadeA)
				v2:subV3(v0,shadeB)
				return vec.strength*shadeC:dotV3(N)/shadeC:magnitudeV3()^3
			end,

			updateScene=function(self,objects,points_new,triangles,cam_x,cam_y,cam_z,cam_yaw,cam_pitch,cam_roll,backface_culling,lights)
				test2=Krolony.Profilers.profileTime('matrix: ',true)
				local c,s,fov,matrix,temporary,triangle_new,triangle,flag,points_g,points,point=math.cos,math.sin,math.tan(self.cam_fov/2*math.atan(self.aspect))
				local cb,sb,ca,sa,cg,sg=c(-cam_pitch),s(-cam_pitch),c(-cam_yaw),s(-cam_yaw),c(-cam_roll),s(-cam_roll)
				matrix=Krolony.Math.Matrix.newM(
					{ca,0,sa,0},--yaw b
					{0,1,0,0},
					{-sa,0,ca,0},
					{0,0,0,1}
				)
				temporary=Krolony.Math.Matrix.newM(
					{1,0,0,0},--pitch y
					{0,cb,-sb,0},
					{0,sb,cb,0},
					{0,0,0,1}
				)
				--matrix=matrix:multiplyM(temporary)
				matrix=temporary:multiplyM(matrix)
				temporary=Krolony.Math.Matrix.newM(
					{cg,-sg,0,0},--roll a
					{sg,cg,0,0},
					{0,0,1,0},
					{0,0,0,1}
				)
				matrix=temporary:multiplyM(matrix) -- Roll * (Pitch * Yaw) = Roll * Pitch * Yaw
				--matrix=matrix:multiplyM(temporary)
				--matrix=matrix:inverseM() --is now rotation matrix
				
				temporary=Krolony.Math.Matrix.newM(
					{1,0,0,-cam_x},
					{0,1,0,-cam_y},
					{0,0,1,-cam_z},
					{0,0,0,1}
				)
				matrix=matrix:multiplyM(temporary)
				temporary=Krolony.Math.Matrix.newM( --perspective matrix
					{1/fov,0,0,0},
					{0,self.aspect/fov,0,0},
					{0,0,self.far_plane/(self.far_plane-self.near_plane),-(self.far_plane*self.near_plane)/(self.far_plane-self.near_plane)},
					--{0,0,self.far_plane+self.near_plane,-self.far_plane*self.near_plane},
					{0,0,1,0}
				)
				--matrix=matrix:multiplyM(temporary)--combine rotation and perspective
				matrix=temporary:multiplyM(matrix)



				local shader,camPos,normal=self.shader,{x=cam_x,y=cam_y,z=cam_z,w=0,strength=1}

				test2:stop()
				test2=Krolony.Profilers.profileTime('update: ',true)
				--[[for i=#triangles+1,#self.triangles do
					self.triangles[i].flag=false
				end
				for i=#self.triangles+1,#triangles do
					self.triangles[i]={mid=vecNew(),normal=vecNew(),dis=0}
				end
				for i=1,#points_new do
					self.points[i]=self.points[i] or vecNew()
					self.points_g[i]=self.points_g[i] or vecNew()
					points=self.points[i]
					points_g=self.points_g[i]--a reuse, would be point_g but that's extra chars so
					
					points_g:setV3(points_new[i].x,points_new[i].y,points_new[i].z,1)
					points:setV3(matrix:multVecM(points_g))
					points.x=points.x/points.w
					points.y=points.y/points.w
				end]]
				self.totalFlags=0
				points=self.points
				points_g=self.points_g
				local pIndex,tIndex,temporary2,temporary=0,0,0,0
				for i,object in pairs(objects) do
					temporary2=temporary2+#object.points
					temporary=temporary+#object.triangles
				end
				for i=#self.points,temporary2 do
					self.points_g[i]=vecNew()
					self.points[i]=vecNew()
				end
				for i=#self.triangles,temporary do
					self.triangles[i]={mid=vecNew(),normal=vecNew(),dis=0}
				end
				for i,object in pairs(objects) do
					ca,cb,cg,sa,sb,sg=object.yaw,object.pitch,object.roll,object.x,object.y,object.z
					temporary=Krolony.Math.Matrix.newM(
						{1,0,0,sa},
						{0,1,0,sb},
						{0,0,1,sg},
						{0,0,0,1}
					)
					cb,sb,ca,sa,cg,sg=c(cb),s(cb),c(ca),s(ca),c(cg),s(cg)
					temporary2=Krolony.Math.Matrix.newM(
						{ca,0,sa,0},
						{0,1,0,0},
						{-sa,0,ca,0},
						{0,0,0,1}
					)
					temporary=temporary2:multiplyM(temporary)
					temporary2=Krolony.Math.Matrix.newM(
						{1,0,0,0},
						{0,cb,-sb,0},
						{0,sb,cb,0},
						{0,0,0,1}
					)
					temporary=temporary:multiplyM(temporary2)
					temporary2=Krolony.Math.Matrix.newM(
						{cg,-sg,0,0},
						{sg,cg,0,0},
						{0,0,1,0},
						{0,0,0,1}
					)
					temporary=temporary2:multiplyM(temporary)
					--temporary2=matrix:multiplyM(temporary)

					for j,newTriangle in ipairs(object.triangles) do
						tIndex=tIndex+1
						triangle=self.triangles[tIndex]
						triangle[1],triangle[2],triangle[3]=newTriangle[1]+pIndex,newTriangle[2]+pIndex,newTriangle[3]+pIndex
						triangle.r,triangle.b,triangle.g=newTriangle.r,newTriangle.b,newTriangle.g
					end
					for j,newPoint in ipairs(object.points) do
						pIndex=pIndex+1
						--points_g[pIndex]:setV3(newPoint.x,newPoint.y,newPoint.z,1)
						point=points_g[pIndex]--global
						vertice=points[pIndex]--screen
						point:setV3(temporary:multVecM(newPoint))
						vertice:setV3(matrix:multVecM(point))
						--point.x,point.y,point.z,point.w=temporary:multVecM(newPoint)
						--vertice.x,vertice.y,vertice.z,vertice.w=matrix:multVecM(point)
						vertice.x=vertice.x/vertice.w
						vertice.y=vertice.y/vertice.w
					end
				end
				for i=tIndex+1,#self.triangles do
					self.triangles[i].flag=false
				end
				test2:stop()

				normal=function(triangle)
					local v0,v1,v2,N=points_g[triangle[1]],points_g[triangle[2]],points_g[triangle[3]],triangle.normal
					local x1,y1,z1,x2,y2,z2=v1.x-v0.x,v1.y-v0.y,v1.z-v0.z,v2.x-v0.x,v2.y-v0.y,v2.z-v0.z --in relation to 1st vertex
					x1,y1,z1=y1*z2-z1*y2,z1*x2-x1*z2,x1*y2-y1*x2 --cross product
					x2=1/(x1*x1+y1*y1+z1*z1)^0.5 --normalization
					N:setV3(x1*x2,y1*x2,z1*x2,0) --skips many calls
				end
				test2=Krolony.Profilers.profileTime('triangles: ',true)
				for i=1,tIndex do--#triangles do
					triangle_new=triangles[i]
					triangle=self.triangles[i]
					flag=0
					local x,y,z,vertice=0,0,0
					for j=1,3 do
						vertice=triangle[j]--triangle_new[j]
						--triangle[j]=vertice
						point=points_g[vertice]
						x=x+point.x
						y=y+point.y
						z=z+point.z
						--/\ /\ /\ midpoint in global space
						--\/ \/ \/ screenspace within -1 to 1
						point=points[vertice]
						flag=flag+(((point.x^2>1) or (point.y^2>1)) and 1 or 0) + (-point.w>self.near_plane and -point.w<self.far_plane and 0 or 9)
					end
					flag=flag<3
					if flag then
						triangle.mid:setV3(x/3,y/3,z/3,0)
						normal(triangle)
						flag=shader(triangle,camPos,points_g)*backface_culling>=0
						if flag then
							triangle.mid:subV3(camPos,shadeA)
							triangle.dis=shadeA:magnitudeV3()
							--triangle.r=triangle_new.r
							--triangle.g=triangle_new.g
							--triangle.b=triangle_new.b
						end
					end
					triangle.flag=flag
					self.totalFlags=self.totalFlags+(flag and 1 or 0)
				end
				test2:stop()

				test2=Krolony.Profilers.profileTime('sort: ',true)
				table.sort(self.triangles,function(a,b) return a.flag and not (b.flag and not (a.dis>b.dis)) end)
				test2:stop()
			end,

			drawTriangles=function(self,x,y,w,h,lights,backface_culling)
				self.aspect=h/w
				w=w/2
				h=h/2
				x=x+w
				y=y+h
				local lasthash,default_light,points_g,points,triangles,color,draw,triangle,p1,p2,p3,hash,r,g,b,hash_agresiveness=-1,#lights==0 and 1 or 0,self.points_g,self.points,self.triangles,screen.setColor,screen.drawTriangleF
				local RGB,min,max,shader,shade,shadeCR,shadeCG,shadeCB,light=Krolony.Screens.correctRGBA,math.min,math.max,self.shader
				hash_agresiveness=0.1--0.005--min 0.001
				for i=1,self.totalFlags do
					triangle=triangles[i]
					r,g,b=triangle.r,triangle.g,triangle.b
					shadeCR,shadeCG,shadeCB=default_light,default_light,default_light
					for j=1,#lights do
						light=lights[j]
						shade=max(0,backface_culling*shader(triangle,light,points_g))
						shadeCR=shadeCR+shade*light.r
						shadeCG=shadeCG+shade*light.g
						shadeCB=shadeCB+shade*light.b
					end
					r,g,b=RGB(min(300,r*shadeCR),min(300,g*shadeCG),min(300,b*shadeCB),0)
					hash=((r/255)^0.5//hash_agresiveness)+(((g/255)^0.5//hash_agresiveness)<<20)+(((b/255)^0.5//hash_agresiveness)<<40)
					if hash~=lasthash then
						color(r,g,b)
						lasthash=hash
					end

					p1,p2,p3=points[triangle[1]],points[triangle[2]],points[triangle[3]]
					draw(p1.x*h+x,p1.y*w+y,p2.x*h+x,p2.y*w+y,p3.x*h+x,p3.y*w+y)
				end
			end,

			drawPixels=function(self,x,y,w,h,lights,backface_culling)
				self.aspect=h/w
				self.screenSpace=self.screenSpace or {}

				w=w/2
				h=h/2
				x=x+w
				y=y+h
				local lasthash,points_g,points,triangles,color,draw,lerp,screenSpace,triangle,x1,x2,x3,y1,y2,y3,p1,p2,p3,z1,z2,z3,hash,r,g,b,d,halfd,halfy=-1,self.points_g,self.points,self.triangles,screen.setColor,screen.drawLine,Krolony.Utilities.lerp,self.screenSpace
				local RGB,min,max,shader,shade,shadeCR,shadeCG,shadeCB,light,inTriangle,orient=Krolony.Screens.correctRGBA,math.min,math.max,self.shader
				for i=x-w,x+w do
					screenSpace[i]=screenSpace[i] or {}
					for j=y-h,y+h do
						screenSpace[i][j]=99999999999
					end
				end
				
				orient=function(A,B,C)
					local v=(B.x-A.x)*(C.y-A.y)-(B.y-A.y)*(C.x-A.x)
					return v>0 and 1 or -1
				end
				inTriangle=function(x,y,triangle,points)
					local A,B,C=points[triangle[1]],points[triangle[2]],points[triangle[3]]
					shadeA:setV3(x,y)
					local v=orient(A,B,shadeA)+orient(B,C,shadeA)+orient(C,A,shadeA)
					return v^2==9
				end
				for i=1,self.totalFlags do
					triangle=triangles[i]

					p1,p2,p3=points[triangle[1]],points[triangle[2]],points[triangle[3]]
					x1=p1.x*h+x
					y1=p1.y*w+y
					x2=p2.x*h+x
					y2=p2.y*w+y
					x3=p3.x*h+x
					y3=p3.y*w+y
					z1,z2,z3=p1.w,p2.w,p3.w

					local minx,maxx,miny,maxy=max(min(x1,x2,x3),x-w),min(x+w,max(x1,x2,x3)),max(y-h,min(y1,y2,y3)),min(y+h,max(y1,y2,y3))
					for sx=minx//1,maxx do
						for sy=miny//1,maxy do
							if inTriangle((sx-x)/w,(sy-y)/h,triangle,points) then
								halfd=lerp(sx,x1,z1,x2,z2)
								halfy=lerp(sx,x1,y1,x2,y2)
								d=lerp(sy,halfy,halfd,y3,z3)
								if screenSpace[sx][sy]>-d then
									screenSpace[sx][sy]=-d
									r,g,b=triangle.r,triangle.g,triangle.b
									shade=#lights==0 and 1 or 0
									shadeCR,shadeCG,shadeCB=shade,shade,shade
									for j=1,#lights do
										light=lights[j]
										shade=max(0,backface_culling*shader(triangle,light,points_g))
										shadeCR=shadeCR+shade*light.r
										shadeCG=shadeCG+shade*light.g
										shadeCB=shadeCB+shade*light.b
									end
									r,g,b=RGB(min(300,r*shadeCR),min(300,g*shadeCG),min(300,b*shadeCB),0)
									hash=((r/255)^0.5//0.005)+(((g/255)^0.5//0.005)<<10)+(((b/255)^0.5//0.005)<<20)
									if hash~=lasthash then
										color(r,g,b)
										lasthash=hash
									end
									draw(sx,sy,sx+1,sy)
								end
							end
						end
					end
				end
			end
		}
	end
	---@endsection
}
---@endsection SPECIALCLASS
---@diagnostic enable:unbalanced-assignments
