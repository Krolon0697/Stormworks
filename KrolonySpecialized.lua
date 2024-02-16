---@diagnostic disable:unbalanced-assignments
---@section Specialized 1 SPECIALCLASS
Krolony.Specialized={

	---@section bitWork 1 BITCLASS
	bitWork={
		---@section floatToBits
		---Converts X into an integer of same bit representation. With infs nans and subnormals
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
		---converts integer back to floating point number with infs nans and subnormals
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
			return sign*2^exponent*((check and 0 or 1)+mantissa/2^mantissaBits)
		end,
		---@endsection

		---@section floatToBitsDry
		---Converts X into an integer of same bit representation. No infs nans subnormals
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
			if mantissa<=2^(-2^(exponentBits-1)+1) then return 0,0 end
			precision=math.log(mantissa,2)//1
			check=mantissa/2^precision
			precision=precision+(check<1 and -1 or check>=2 and 1 or 0) --correct for inaccurate log :rolling_eyes:
			exponent=math.min(2^exponentBits-1,2^(exponentBits-1)-1+precision)
			mantissa=((mantissa/2^precision-1)*2^mantissaBits+0.5)//1

			return sign+exponent,(mantissa+0.5)//1
		end,
		---@endsection

		---@section bitsToFloatDry
		---converts integer back to floating point number, no infs nans subnormals
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

	---@section fitPolyConstructor
	---very resource expensive, the more data you have the worse it is, but it does a decent fit, progressively gets better, data table {{x,y},{x,y}} that you want to fit, speed how many paths it checks per call, provide with memory table, returns table of a polynomial {a0,a1,a2}
	---@param amtOfCoefs integer how many coefficient it has to work with
	---@return table object with method
	fitPolyConstructor=function(amtOfCoefs)
		local coefs={}
		for i=1,amtOfCoefs do
			coefs[i]=1
		end
		return {
			iters=0,
			step=1,
			error=1,
			coefs=coefs,
			k=1,
			---@param self table
			---@param data table {{x,y},{x,y},...} data to fit to
			---@param errorFunction function function(coefficients,data) that outputs the error between data and a function with given coefficients
			---@param speed integer how many iterations it does per call
			---@return table coefficients {1,2,3,...}
			---@return number stepsize the change of coefficients it last checked
			---@return number error of the last processed coefficients
			---@return number iterations total amount of checked combinations
			run=function(self,data,errorFunction,speed)
				local coefsCheck,rnd,possibilities,checked,step,errSaved,errCheck,k,coefsSaved={},math.random
				step,errSaved,coefsSaved,k,checked=self.step,errorFunction(self.coefs,data),self.coefs,self.k,self.checked
				possibilities=3^amtOfCoefs
				for i=1,speed do
					checked=checked+1
					if checked>possibilities then
						step,checked=step*rnd(),1
						step=step>0 and step or 2^20
					end
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
						self.iters=self.iters+1
						checked=0
					end
				end
				self.step=step--2
				self.error=errSaved--3
				self.k=k--5
				self.checked=checked--6
				return coefsSaved,step,errSaved,self.iters
			end
		}
	end,
	---@endsection

	---@section Ballistics2D

	---optimized physics simulation to eyeball the required elevation, no speed correction nor leading, elev in radians, velocity of gun in m/s, lifetime in ticks, drag as posted by devs, indirect fire is a bool, returns a radian, can't reach bool and flighttime in ticks
	Ballistics2D=function(x,y,elevation,velocity,drag,lifetime,indirect)
		local x,y,tx,ty,vx,vy=0,0,x,y
		local e,v,d,l,g,step,t,bad=elevation,velocity,1-drag,lifetime,30/3600,1,0
		local pi=math.pi

		vx,vy=v*math.cos(e)/60,v*math.sin(e)/60
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
		return e,y,bad,t,((tx-x)^2+(ty-y)^2)^0.5
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
		--t=math.log(1+x*(self.d-1)/vel)/math.log(self.d)//1
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

	---@section createGameEngine
	createGameEngine=function(near_plane,far_plane,cam_fov)
		local vecNew,s,c,rotMat,vecA,vecB,vecC=Krolony.Math.Vec3.newV3,math.sin,math.cos
		rotMat=function(yaw,pitch,roll)
			local cy,sy,cp,sp,cr,sr=c(yaw),s(yaw),c(pitch),s(pitch),c(roll),s(roll)
			return {
				{cr*cy-sr*sp*sy,-sr*cp,cr*sy+sr*sp*cy},
				{sr*cy+cr*-sp*-sy,cr*cp,sr*sy-cr*sp*cy},
				{-cp*sy,sp,cp*cy},
				{0,0,0,1},
				multVecM=function(mat,vec)
					return mat[1][1]*vec.x+mat[1][2]*vec.y+mat[1][3]*vec.z+mat[1][4]*vec.w,
						mat[2][1]*vec.x+mat[2][2]*vec.y+mat[2][3]*vec.z+mat[2][4]*vec.w,
						mat[3][1]*vec.x+mat[3][2]*vec.y+mat[3][3]*vec.z+mat[3][4]*vec.w,
						mat[4][1]*vec.x+mat[4][2]*vec.y+mat[4][3]*vec.z+mat[4][4]*vec.w
				end
			}
		end
		vecA,vecB,vecC=vecNew(),vecNew(),vecNew()
		return {
			total_ids=0,
			objects={},
			triangles={},
			points={},
			screenspace={},
			near_plane=near_plane,
			far_plane=far_plane,
			cam_fov=cam_fov,

			---@section instantiate
			instantiate=function(self,points,triangles,position,yaw,pitch,roll,id)
				self.total_ids=self.total_ids+1
				id=id or self.total_ids
				self.objects[id]={
					points={},
					points_g={},
					triangles={},
					position=position,
					yaw=yaw,
					pitch=pitch,
					roll=roll
				}
				local object,triangle=self.objects[id]
				for i=1,#points do
					object.points_g[i]=vecNew()
					object.points[i]=vecNew(points[i].x,points[i].y,points[i].z)
				end
				for i=1,#triangles do
					object.triangles[i]={mid=vecNew(),normal=vecNew(),table.unpack(triangles[i])}
					triangle=object.triangles[i]
					triangle.r=triangles[i].r
					triangle.g=triangles[i].g
					triangle.b=triangles[i].b

				end
				self:updateGlobalSpace(id)
			end,
			---@endsection

			
			---@section change_object_placement
			change_object_placement=function(self,id,position,yaw,pitch,roll)
				local object=self.objects[id]
				if object then
					object.position=position
					object.yaw=yaw
					object.pitch=pitch
					object.roll=roll
					self:updateGlobalSpace(id)
				end
			end,
			---@endsection

			--[[
			physicsSimple=function(self)
				--check collissions
				local objects=self.objects
				for id1,object1 in next,objects do
					for id2,object2 in next,objects,id1 do
						object1.pos:subV3(object2.pos,vecA)
						if vecA:magnitudeV3()<object1.bounding_radius+object2.bounding_radius then
							

						end
					end
				end

				--add forces -> acceleration -> speed -> position

				--0 forces so that they can be added outside
			end,]]

			---@section updateGlobalSpace
			updateGlobalSpace=function(self,id)
				local object,points_g,triangle,matrix=self.objects[id]
				points_g=object.points_g
				local cx,cy,cz,x,y,z,sx,sy,sz={object.position.x,object.position.y,object.position.z}
				matrix=rotMat(object.yaw,object.pitch,object.roll)
				for i=1,3 do
					matrix[i][4]=cx[i]
				end
				for j=1,#object.points do
					points_g[j]:setV3(matrix:multVecM(object.points[j]))
				end
				for j=1,#object.triangles do
					triangle=object.triangles[j]
					x,y,z=points_g[triangle[1]],points_g[triangle[2]],points_g[triangle[3]]
					cx,cy,cz,sx,sy,sz=y.x-x.x,y.y-x.y,y.z-x.z,z.x-x.x,z.y-x.y,z.z-x.z --in relation to 1st vertex
					--cy,cp,cr=cp*sr-cr*sp,cr*sy-cy*sr,cy*sp-cp*sy --cross product
					--sy=1/(cy*cy+cp*cp+cr*cr)^0.5 --normalization
					--triangle.normal:setV3(cy*sy,cp*sy,cr*sy) --skips many calls
					vecA:setV3(cy*sz-cz*sy,cz*sx-cx*sz,cx*sy-cy*sx)
					--vecA:unitV3(triangle.normal)
					sy=vecA:magnitudeV3()
					triangle.normal:setV3(vecA.x/sy,vecA.y/sy,vecA.z/sy)

					x:addV3(y,vecA)
					vecA:addV3(z,vecB)
					triangle.mid:setV3(vecB.x/3,vecB.y/3,vecB.z/3)
					--triangle.mid.strength=1
				end
			end,
			---@endsection

			---@section drawScene
			drawScene=function(self,x,y,w,h,cam_pos,cam_yaw,cam_pitch,cam_roll,lights,backface_culling,hash_agresiveness)
				w=w/2
				h=h/2
				x=x+w
				y=y+h
				local min,max,color,draw,aspect,pixels=math.min,math.max,screen.setColor,screen.drawTriangleF,h/w,self.screenspace
				local fov,triangles,objects,counter,lasthash,default_light,near,far,points,hash,shade,triangle,matrix,object,flag,vec,shader,r,g,b,shadeCR,shadeCG,shadeCB=math.tan(self.cam_fov/2*math.atan(aspect)),self.triangles,self.objects,0,-1,#lights==0 and 1 or 0,self.near_plane,self.far_plane,self.points
				matrix=rotMat(-cam_yaw,-cam_pitch,-cam_roll)
				for i=1,3 do--translation
					matrix[i][4]=-matrix[i][1]*cam_pos.x-matrix[i][2]*cam_pos.y-matrix[i][3]*cam_pos.z
				end
				hash={aspect/fov,1/fov,-(far+near)/(far-near)}
				for i=1,4 do--perspective
					matrix[4][i]=-matrix[3][i]
					for j=1,3 do
						matrix[j][i]=matrix[j][i]*hash[j]
					end
				end
				matrix[3][4]=matrix[3][4]-2*(far*near)/(far-near)

				shader=function(normal,vec,tria_pos)
					--local normal=triangle.normal
					vecC:setV3(tria_pos.x-vec.x,tria_pos.y-vec.y,tria_pos.z-vec.z)
					--local mid,normal=triangle.mid,triangle.normal
					--vecC:setV3(mid.x-vec.x,mid.y-vec.y,mid.z-vec.z)
					--return vec.strength*vecC:dotV3(triangle.normal)/vecC:magnitudeV3()^3
					return vec.strength/vecC:magnitudeV3()^3*(vecC.x*normal.x+vecC.y*normal.y+vecC.z*normal.z)--+vecC.w*normal.w)
				end

				--[[
				perspective=Krolony.Math.Matrix.newM(
					{aspect/fov,0,0,0},
					{0,1/fov,0,0},
					{0,0,-(far+near)/(far-near),-(far*near)/(far-near)},
					--{0,0,far+near,-far*near},
					{0,0,-1,0}
				)
				matrix=Krolony.Math.Matrix.multiplyM(matrix,perspective)]]
				cam_pos.strength=cam_pos.strength or 1
				--cam_pos.normal=vecNew(-c(cam_pitch)*s(cam_yaw),s(cam_pitch),-c(cam_pitch)*c(cam_yaw))
				--cam_pos.mid=cam_pos
				hash=0
				for key,object in next,objects do
					for index,point in next,object.points_g do
						points[index+hash]=points[index+hash] or vecNew()
						points[index+hash]:setV3(point.x,point.y,point.z)
					end
					r=object.points_g
					for index,obtriangle in next,object.triangles do
						if shader(obtriangle.normal,cam_pos,obtriangle.mid)*backface_culling>0 then-- and shader(cam_pos,obtriangle.mid)*backface_culling>0 then
							flag=0
							b=0
							for i=1,3 do
								shade=obtriangle[i]
								g=shade+hash
								vec=points[g]
								if vec.w then
									vec:setV3(matrix:multVecM(r[shade]))
									vec.x=vec.x/vec.w
									vec.y=vec.y/vec.w
									vec.z=vec.z/vec.w
									vec.w=nil
								end
								b=b+vec.z
								flag=flag+((vec.x^2>1 or vec.y^2>1) and 1 or 0) + (vec.z^2>1 and 9 or 0)
							end
							if flag<3 then
								counter=counter+1
								triangles[counter]=triangles[counter] or {}
								triangle=triangles[counter]
								triangle.dis=b
								triangle.key=key
								triangle.index=index
								triangle.offset=hash
							end
						end
					end
					hash=hash+#object.points_g
				end
				for i=counter+1,#triangles do
					triangles[i]=nil
				end
				table.sort(triangles,function(a,b) return a.dis>b.dis end)
				for px=x-w,x+w do
					pixels[px]=pixels[px] or {}
					for py=y-h,y+h do
						pixels[px][py]=2
					end
				end
				for i=counter,1,-1 do
					triangle=triangles[i]
					object=objects[triangle.key]
					flag=triangle.offset
					triangle=object.triangles[triangle.index]
					r,g,b=points[flag+triangle[1]],points[flag+triangle[2]],points[flag+triangle[3]]
					flag=false
					for px=0,0 do
						
						
					end
				end
				for i=1,counter do
					triangle=triangles[i]
					object=objects[triangle.key]
					flag=triangle.offset
					triangle=object.triangles[triangle.index]
					near=triangle.normal
					far=triangle.mid
					shadeCR,shadeCG,shadeCB=default_light,default_light,default_light
					for i,light in next,lights do
						shade=max(0,backface_culling*shader(near,light,far))
						shadeCR=shadeCR+shade*light.r
						shadeCG=shadeCG+shade*light.g
						shadeCB=shadeCB+shade*light.b
					end--0.004ms per light per 5000 triangles
					r,g,b=min(255,triangle.r*shadeCR),min(255,triangle.g*shadeCG),min(255,triangle.b*shadeCB)
					hash=r/255//hash_agresiveness+((g/255//hash_agresiveness)<<20)+((b/255//hash_agresiveness)<<40)
					if hash~=lasthash then
						color(255*(r/255)^2.4,255*(g/255)^2.4,255*(b/255)^2.4)
						lasthash=hash
					end--0.001ms per triangle + color head
					
					r,g,b=points[flag+triangle[1]],points[flag+triangle[2]],points[flag+triangle[3]]
					draw(r.x*w+x,r.y*h+y,g.x*w+x,g.y*h+y,b.x*w+x,b.y*h+y)--the brunt
				end
			end,
			---@endsection

			--[[
			drawPixels=function(self,x,y,w,h,lights,backface_culling)
				self.aspect=h/w
				self.screenSpace=self.screenSpace or {}

				w=w/2
				h=h/2
				x=x+w
				y=y+h
				local lasthash,points_g,points,triangles,color,draw,lerp,screenSpace,triangle,cy,sy,x3,cp,sp,y3,p1,p2,p3,cr,sr,z3,hash,r,g,b,d,halfd,halfy=-1,self.points_g,self.points,self.triangles,screen.setColor,screen.drawLine,Krolony.Utilities.lerp,self.screenSpace
				local RGB,min,max,shader,shade,shadeCR,shadeCG,shadeCB,light,inTriangle,orient=Krolony.Screens.correctRGBA,math.min,math.max,self.shader
				for i=x-w,x+w do
					screenSpace[i]=screenSpace[i] or {}
					for j=y-h,y+h do
						screenSpace[i][j]=self.far_plane
					end
				end
				
				orient=function(A,B,C)
					local v=(B.x-A.x)*(C.y-A.y)-(B.y-A.y)*(C.x-A.x)
					return v>0 and 1 or -1
				end
				inTriangle=function(x,y,triangle,points)
					local A,B,C=points[triangle[1]]--,points[triangle[2]],points[triangle[3]]
					--[[vecA:setV3(x,y)
					local v=orient(A,B,vecA)+orient(B,C,vecA)+orient(C,A,vecA)
					return v^2==9
				end
				for i=1,self.totalFlags do
					triangle=triangles[i]

					p1,p2,p3=points[triangle[1]]--,points[triangle[2]],points[triangle[3]]
					--[[cy=p1.x*h+x
					cp=p1.y*w+y
					sy=p2.x*h+x
					sp=p2.y*w+y
					x3=p3.x*h+x
					y3=p3.y*w+y
					cr,sr,z3=p1.w,p2.w,p3.w

					local minx,maxx,miny,maxy=max(min(cy,sy,x3),x-w),min(x+w,max(cy,sy,x3)),max(y-h,min(cp,sp,y3)),min(y+h,max(cp,sp,y3))
					for sx=minx//1,maxx do
						for sy=miny//1,maxy do
							if inTriangle((sx-x)/w,(sy-y)/h,triangle,points) then
								halfd=lerp(sx,cy,cr,sy,sr)
								halfy=lerp(sx,cy,cp,sy,sp)
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
			end]]
		}
	end
	---@endsection
}
---@endsection SPECIALCLASS
---@diagnostic enable:unbalanced-assignments
