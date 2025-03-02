---@section KL_Graphica 1 KL_GRAPHICACLASS
--EVERYTHING screens, color manipulation, buttons
KineticaL.KL_Graphica={
	
	---@section KL_gammaCor
	---correct for filthy SW displays, range 0-255, returns r,g,b,a
	---@param r number
	---@param g number
	---@param b number
	---@param a number
	---@return number red
	---@return number green
	---@return number blue
	---@return number alpha
	KL_gammaCor=function(r,g,b,a)
		local gamma,k=2.4,0.85
		return 255*(k*r/255)^gamma,255*(k*g/255)^gamma,255*(k*b/255)^gamma,255*(k*a/255)^gamma
	end,
	---@endsection

	---@section KL_hsvToRgb
	---changes HSV into RGB and corrects it's gamma for the filfthy SW displays
	---@param h number hue  0-359 (360 wraps)
	---@param s number saturation 0-1
	---@param v number value 0-1
	---@param alpha number|nil alpha 0-1 defaults to to 1
	---@return number red 0-255
	---@return number green 0-255
	---@return number blue 0-255
	---@return number alpha 0-255
	KL_hsvToRgb=function(h,s,v,alpha)
		local gamma,abs=KineticaL.Graphica.gammaCor,math.abs
		local alpha,c,i,d,x,m=alpha or 1,v*s,(h%360)//60+1
		x,m=c*(1-abs((h/60)%2-1)),v-c
		d={{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}}
		return gamma((d[i][1]+m)*255,(d[i][2]+m)*255,(d[i][3]+m)*255,alpha*300)
	end,
	---@endsection

	---@section KL_createButton
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
	KL_createButton=function(x,y,w,h,onRGBA,offRGBA,mode,txt,drawTxt)
		local sp,sh,st,setColor,unpack,drawRect,drawText='pulse','hold','toggle',screen.setColor,table.unpack,screen.drawRect,screen.drawText
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
			KL_manage=function(self,x,y,press)
				local hold=x>=self.x and x<=self.x+self.w and y>=self.y and y<=self.y+self.h and press and self.active
				self.timer=hold and self.timer+1 or 0
				self.state=self.mode==sp and self.timer==1 or self.mode==sh and self.timer>0 or self.mode==st and self.state
				if self.mode==st and self.timer==1 then self.state=not self.state end
			end,
			---if is active then it draws the button according to the data inside of button
			---@param self table
			KL_draw=function(self)
				if self.active then
					setColor(unpack(self.state and self.onRGBA or self.offRGBA))
					drawRect(self.x,self.y,self.w,self.h)
					if self.drawTxt then drawText(self.x+2,self.y+2,self.txt) end
				end
			end
		}
	end,
	---@endsection

	---@section KL_dialCreator
	---creates a dial object which can be worked on by using it's methods
	---@param center_x number
	---@param center_y number
	---@param width number the width of the dial face
	---@param height number the height of the dial face
	---@param orientation_angle number angle at which dial face is rotated
	---@param arc_segments number integer of how many segments there are for the dial face
	---@param arc_radians number angle on how much of a circle (or ellipse) there is, 0-2pi
	---@param antiAliasing number integer 0 for no aliasing and as high as you want
	---@param r number
	---@param g number
	---@param b number
	---@return table object
	KL_dialCreator=function(center_x,center_y,width,height,orientation_angle,arc_segments,arc_radians,antiAliasing,r,g,b)
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
			---adds a group of marks to the dial
			---@param self table
			---@param inside number how much inside of the dial face these marks go
			---@param outside number how much outside of the dial face these marks go
			---@param amount number integer of how many marks there are
			---@param r number
			---@param g number
			---@param b number
			KL_insertMark=function(self,inside,outside,amount,r,g,b)
				table.insert(self.marks,{inside=inside,outside=outside,amount=amount,r=r,g=g,b=b})
			end,
			---adds an arrow to the dial
			---@param self table
			---@param arrowID number integer starting at 1, uses ipairs() internally so don't leave holes
			---@param length number how long the arrow tip is
			---@param width number how wide the base of arrow is
			---@param r number
			---@param g number
			---@param b number
			KL_insertArrow=function(self,arrowID,length,width,r,g,b)
				self.arrows[arrowID]={length=length,width=width,r=r,g=g,b=b,pos=0}
			end,
			---updates arrow position
			---@param self table
			---@param arrowID number integer, id of the arrow
			---@param value number 0-1 to go from leftmost mark to the rightmost mark
			KL_update=function(self,arrowID,value)
				self.arrows[arrowID].pos=value
			end,
			KL_draw=function(self)
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
	end,
	---@endsection

	---@section KL_create_Render 1 KL_RENDERCLASS
	KL_create_Render=function()
		local s,c,newVec,next,ipairs,unpack,insert,remove,quickVecMult,rotMat,ray_against_recursive_boxes,AABB_ray_intersect,ray_origin,ray_direction,sacrificial_vec=math.sin,math.cos,KineticaL.Nuclea.Vectors.newV,next,ipairs,table.unpack,table.insert,table.remove,
		function(mat,vec,flag4)
			if flag4 then
				return	mat[1][1]*vec[1]+mat[1][2]*vec[2]+mat[1][3]*vec[3]+mat[1][4]*vec[4],
						mat[2][1]*vec[1]+mat[2][2]*vec[2]+mat[2][3]*vec[3]+mat[2][4]*vec[4],
						mat[3][1]*vec[1]+mat[3][2]*vec[2]+mat[3][3]*vec[3]+mat[3][4]*vec[4],
						mat[4][1]*vec[1]+mat[4][2]*vec[2]+mat[4][3]*vec[3]+mat[4][4]*vec[4]
			else
				return	mat[1][1]*vec[1]+mat[1][2]*vec[2]+mat[1][3]*vec[3],
						mat[2][1]*vec[1]+mat[2][2]*vec[2]+mat[2][3]*vec[3],
						mat[3][1]*vec[1]+mat[3][2]*vec[2]+mat[3][3]*vec[3]
			end
		end
		function rotMat(yaw,pitch,roll,fill)
			local cy,sy,cp,sp,cr,sr=c(-yaw),s(-yaw),c(-pitch),s(-pitch),c(roll),s(roll)
			return KineticaL.Nuclea.Matrices.newTM(
				{cr*cy-sr*sp*sy,-sr*cp,cr*sy+sr*sp*cy,fill},
				{sr*cy+cr*-sp*-sy,cr*cp,sr*sy-cr*sp*cy,fill},
				{-cp*sy,sp,cp*cy,fill},
				{0,0,0,1}
			)
		end
		ray_origin,ray_direction,sacrificial_vec=newVec(),newVec(),newVec()
		function AABB_ray_intersect(box_min,box_max,origin,direction)
			local t_min,t_max,v,t_low,t_high=-1/0,1/0
			for i=1,3 do
				t_low=(box_min[i]-origin[i])/direction[i]
				t_high=(box_max[i]-origin[i])/direction[i]
				v=t_low<t_high and t_low or t_high
				t_min=v>t_min and v or t_min
				v=t_low>t_high and t_low or t_high
				t_max=v<t_max and v or t_max
			end
			return t_max>0 and t_min<t_max and t_min
		end
		function ray_against_recursive_boxes(box)
			local distance=AABB_ray_intersect(box.min,box.max,ray_origin,ray_direction)
			if distance and box.children then
				return ray_against_recursive_boxes(box.children[1]) or ray_against_recursive_boxes(box.children[2])
			end
			return distance
		end
		return {
			models={},
			objects={},
			screen_triangles={},
			screen_points={},
			w=1,
			h=1,
			last_run=1,

			---@section KL_load_compressed_model_string
			KL_load_compressed_model_string=function(self,data,model_id)
				local tab,decode,chars_per_word,val={},KineticaL.Cryptica.Formata.decode_SSBIS
				chars_per_word,data=decode(data,1)
				repeat
					val,data=decode(data,chars_per_word)
					insert(tab,val)
				until #data==0
				self:load_compressed_model_table(tab,model_id)
			end,
			---@endsection

			---@section KL_load_compressed_model_table
			KL_load_compressed_model_table=function(self,data,model_id)
				--[[
					word size for header
					transcribed_to

					1	1 to denote compressed
					2	transcribed from (word_size)
					3	float words
					4	face index words
					5	words for colors
					6	amount of bounding boxes
					7	size of file
				]]
				local bounding_boxes,header,materials,vertices,faces,index,formats,bounding_box_count={},{},{},{},{},3,KineticaL.Cryptica.Formata,0
				local decode_SIT,int_to_float,transcribed,count,val,bits,subtable,word_size,color_words,float_words,face_index_words,boxes_count,recursive,wtf_is_that_format_error=formats.decode_SIT,formats.int_To_Float_Dry
				for i=1,7 do
					header[i],index=decode_SIT(data,data[2],data[1],index)
				end
				if header[1]~=1 then wtf_is_that_format_error() end
				word_size=header[2]
				float_words=header[3]
				face_index_words=header[4]
				color_words=header[5]
				boxes_count=header[6]
				transcribed=formats.transcribe(data,data[2],word_size,header[7],index)

				--bounding boxes
				index=1
				bits=word_size*float_words
				recursive=function(current_node)
					bounding_box_count=bounding_box_count+1
					current_node.min={[4]=1}
					current_node.max={[4]=1}
					insert(current_node,current_node.min)
					insert(current_node,current_node.max)
					for i=1,3 do
						for j=1,2 do
							val,index=decode_SIT(transcribed,word_size,float_words,index)
							current_node[j][i]=int_to_float(val,bits)
						end
					end
					remove(current_node,2)
					remove(current_node,1)
					index=index+1
					if transcribed[index-1]==1 and bounding_box_count<boxes_count then
						current_node.children={{},{}}
						recursive(current_node.children[1])
						recursive(current_node.children[2])
					end
				end
				recursive(bounding_boxes)

				local function repetetive(tab,words_amt,entries_count,read_count)
					count,index=decode_SIT(transcribed,word_size,read_count,index)
					for i=1,count do
						subtable={}
						for j=1,entries_count do
							subtable[j],index=decode_SIT(transcribed,word_size,words_amt,index)
						end
						insert(tab,subtable)
					end
				end

				repetetive(materials,color_words,8,face_index_words)
				repetetive(vertices,float_words,3,face_index_words)
				repetetive(faces,face_index_words,4,2*face_index_words)

				for i,vec in ipairs(vertices) do
					for i=1,3 do
						vec[i]=int_to_float(vec[i],bits)
					end
				end

				bits=word_size*color_words
				for i,mat in ipairs(materials) do
					mat.diffuse={}
					mat.specular={}
					for i=1,3 do
						mat.diffuse[i]=mat[2*i-1]<<(8-bits)
						mat.specular[i]=mat[2*i]<<(8-bits)
					end
					mat.opacity=mat[7]<<(8-bits)
					mat.specular_exponent=mat[8]<<(10-bits)
					for i=8,1,-1 do
						remove(mat,i)
					end
				end
				self:load_model(bounding_boxes,materials,vertices,faces,model_id)
			end,
			---@endsection

			KL_load_model=function(self,bounding_boxes,materials,vertices,faces,model_id)
				local model,temp1,temp2,mid,normal,vertice,material={bounding_boxes=bounding_boxes,faces={},vertices={}},newVec(),newVec()
				for i,v in ipairs(vertices) do
					model.vertices[i]=newVec()
					model.vertices[i]:setV4(unpack(v))
				end
				vertices=model.vertices
				for i,face in ipairs(faces) do
					mid=newVec(0,0,0,1)
					for i=1,3 do
						vertice=vertices[face[i] ]
						mid:addV3(vertice,mid)
					end
					mid:scaleV3(1/3,mid)

					vertices[face[2] ]:subV3(vertices[face[1] ],temp2)
					vertices[face[3] ]:subV3(vertices[face[1] ],temp1)
					normal=newVec(temp1[2]*temp2[3]-temp1[3]*temp2[2],temp1[3]*temp2[1]-temp1[1]*temp2[3],temp1[1]*temp2[2]-temp1[2]*temp2[1],1)
					normal:unitV3(normal)

					material=materials[face[4] ]
					insert(model.faces,{
						mid=mid,
						normal=normal,
						material=material,
						unpack(face)
					})
				end
				self.models[model_id]=model
			end,

			KL_instantiate=function(self,model_id,id)
				local faces,model,object={},self.models[model_id]
				object={
					model=model,
					faces=faces,
					screen_triangles={},
					occluded=0
				}
				self.objects[id]=object
				for i,model_face in ipairs(model.faces) do
					insert(faces,{
						mid=newVec(),
						normal=newVec(),
						object=object,
						r=0,g=0,b=0,a=model_face.material.opacity,
						material=model_face.material,
						--model_face[1],
						--model_face[2],
						--model_face[3],
						unpack(model_face)
					})
				end
			end,

			KL_updateObject=function(self,id,position,scale,yaw,pitch,roll)
				local object,matrix,model_faces,inverse_matrix,rotate,unrotate_matrix,translate=self.objects[id]
				rotate=rotMat(-yaw,pitch,roll,0)
				unrotate_matrix=rotate:transposeM()
				translate=KineticaL.Nuclea.Matrices.newTM(
					{1,0,0,position[1]},
					{0,1,0,position[2]},
					{0,0,1,position[3]},
					{0,0,0,1}
				)
				scale=KineticaL.Nuclea.Matrices.newTM(
					{scale[1],0,0,0},
					{0,scale[2],0,0},
					{0,0,scale[3],0},
					{0,0,0,1}
				)
				matrix=translate:multiplyM(rotate):multiplyM(scale)
				for i=1,3 do
					translate[i][4]=-translate[i][4]
					scale[i][i]=1/scale[i][i]
				end
				inverse_matrix=scale:multiplyM(unrotate_matrix):multiplyM(translate)
				model_faces=object.model.faces
				for index,face in ipairs(object.faces) do
					face.normal:setV3(quickVecMult(rotate,model_faces[index].normal))
					face.mid:setV4(quickVecMult(matrix,model_faces[index].mid,1))
				end
				object.position=position
				object.matrix=matrix
				object.unrotate_matrix=unrotate_matrix
				object.inverse_matrix=inverse_matrix
			end,

			KL_killObject=function(self,id)
				self.objects[id]=nil
			end,

			KL_updateScreen=function(self,near_plane,far_plane,fov,cam_pos,cam_yaw,cam_pitch,cam_roll)
				local w,h=self.w/2,self.h/2
				local cam_distance,fov,screen_triangles,objects,screen_triangle_counter,screen_points,w2,h2,vertice_counter=sacrificial_vec,math.tan(fov/2*math.atan(h/w)),self.screen_triangles,self.objects,0,self.screen_points,w^2,h^2,0
				local temporary,point_index,matrix,flag,vec,model_points,current_run,depth,vx,vy,vz,vw,flag1,flag2,flag3,object_triangle_counter,object_screen_triangles,cam_d1,cam_d2,cam_d3,norm1,norm2,norm3,normal,mid
				matrix=rotMat(cam_yaw+math.pi,-cam_pitch,-cam_roll)
				for i=1,3 do--translation
					matrix[i][4]=-matrix[i][1]*cam_pos[1]-matrix[i][2]*cam_pos[2]-matrix[i][3]*cam_pos[3]
				end
				temporary={h/w/fov,1/fov,-(far_plane+near_plane)/(far_plane-near_plane)}
				for i=1,4 do--perspective
					matrix[4][i]=-matrix[3][i]
					for j=1,3 do
						matrix[j][i]=matrix[j][i]*temporary[j]
					end
				end
				matrix[3][4]=matrix[3][4]-2*(far_plane*near_plane)/(far_plane-near_plane)

				current_run=self.last_run+1
				for key,object in next,objects do
					local matrix=matrix:multiplyM(object.matrix)
					vx,vy,vz,vw=quickVecMult(matrix,object.model.bounding_boxes.min,1)
					vx,vy,vz=vx/vw,vy/vw,vz/vw
					flag1=vx>1 and 1 or vx<-1 and -1 or 0
					flag2=vy>1 and 1 or vy<-1 and -1 or 0
					flag3=vz^2<1
					vx,vy,vz,vw=quickVecMult(matrix,object.model.bounding_boxes.max,1)
					vx,vy,vz=vx/vw,vy/vw,vz/vw
					flag=flag1*vx<=1 and flag2*vy<=1 and (flag3 or vz^2<1)
					--print(flag)
					object.in_frustum=flag
					object_triangle_counter=0
					object_screen_triangles=object.screen_triangles
					if flag and object.occluded<self.last_run-1 then
						model_points=object.model.vertices

						for index=#screen_points+1,vertice_counter+#model_points do
							screen_points[index]=newVec()
						end

						for index,triangle in ipairs(object.faces) do
							--back face culling
							mid=triangle.mid
							normal=triangle.normal

							cam_d1=mid[1]-cam_pos[1]
							cam_d2=mid[2]-cam_pos[2]
							cam_d3=mid[3]-cam_pos[3]
							--mid:sub3(cam_pos,cam_distance)
							if cam_d1*normal[1]+cam_d2*normal[2]+cam_d3*normal[3]>0 then--cam_distance:dot3(normal)>=0 then
								flag=0
								depth=0
								for i=1,3 do
									point_index=triangle[i]
									vec=screen_points[point_index+vertice_counter]
									if vec.w==current_run then
										flag=flag+vec.flag
									else
										vx,vy,vz,vw=quickVecMult(matrix,model_points[point_index],1)
										vx,vy,vz=vx/vw*w,vy/vw*h,vz/vw
										--vec:set4(vx,vy,vz,current_run)
										vec[1]=vx
										vec[2]=vy
										vec[3]=vz
										vec[4]=current_run
										depth=depth+vz--there is no point dividing that by 3
										flag=flag+((vx^2>w2 or vy^2>h2) and 1 or 0) + (vz^2>1 and 9 or 0)
										vec.flag=flag
									end
								end
								if flag<3 then
									screen_triangle_counter=screen_triangle_counter+1
									screen_triangles[screen_triangle_counter]=triangle
									object_triangle_counter=object_triangle_counter+1
									object_screen_triangles[object_triangle_counter]=triangle
									triangle.sort=depth
									--for i=4,6 do
									--	triangle[i]=screen_points[triangle[i-3]+vertice_counter]
									--end
									triangle[4]=screen_points[triangle[1]+vertice_counter]
									triangle[5]=screen_points[triangle[2]+vertice_counter]
									triangle[6]=screen_points[triangle[3]+vertice_counter]
									triangle.r,triangle.g,triangle.b=0,0,0
								end
							end
						end
						vertice_counter=vertice_counter+#model_points
					end
					for i=#object_screen_triangles,object_triangle_counter+1,-1 do
						remove(object_screen_triangles,i)
					end
				end
				--there is no point deleting global vertices as they're not sorted
				--but triangles are sorted
				--and it does affect speed
				for i=#screen_triangles,screen_triangle_counter+1,-1 do
					remove(screen_triangles,i)
				end
				table.sort(screen_triangles,function(a,b) return a.sort>b.sort end)
				self.last_run=current_run
				cam_pos[4]=1
				self.camera_position=cam_pos
			end,

			---@section KL_check_occlusions
			KL_check_occlusions=function(self)
				local camera_position,corner=self.camera_position,sacrificial_vec
				local occluded_box,occluding_box,occluded_counter,flag
				for i1,occluded_object in next,self.objects do
					if occluded_object.in_frustum then
						for i2,occluding_object in next,self.objects do
							flag=camera_position:subV3(occluded_object.position,sacrificial_vec):magnitudeV3()
							flag=flag>camera_position:subV3(occluding_object.position,sacrificial_vec):magnitudeV3()
							if i1~=i2 and occluding_object.in_frustum and flag then
								occluded_box=occluded_object.model.bounding_boxes
								occluding_box=occluding_object.model.bounding_boxes
								occluded_counter=0
								for corner_index=1,8 do
									for dim=1,3 do
										flag=(corner_index-1)&(1<<(dim-1))~=0 --all hail gpt
										corner[dim]=flag and occluded_box.min[dim] or occluded_box.max[dim]
									end
									corner[4]=1
									ray_origin:setV4(quickVecMult(occluding_object.inverse_matrix,camera_position,1))
									corner:setV4(quickVecMult(occluded_object.matrix,corner,1))
									corner:subV3(camera_position,ray_direction)
									ray_direction:unitV3(ray_direction)
									ray_direction:setV3(quickVecMult(occluding_object.unrotate_matrix,ray_direction))
									if ray_against_recursive_boxes(occluding_box) then
										occluded_counter=occluded_counter+1
									else
										break
									end
								end
								occluded_object.occluded=occluded_counter==8 and self.last_run or 0
							end
						end
					end
				end
			end,
			---@endsection

			---@param hash_agresiveness integer negative full accuracy 0 very high accuracy 1 high 2 medium 3 low 4 very low quality. And 5 would scale at "gouge my eyes out". Higher doesn't really work
			KL_drawTriangles=function(self,x,y,w,h,hash_agresiveness)
				local color,draw,lasthash,r,g,b,hash,a=screen.setColor,screen.drawTriangleF,-1
				self.w=w
				self.h=h
				x=x+w/2
				y=y+h/2 --because 0,0 is center and -1 to 1 are edges
				for index, triangle in ipairs(self.screen_triangles) do
					r,g,b,a=triangle.r,triangle.g,triangle.b,triangle.a
					r=r<=255 and r or 255
					g=g<=255 and g or 255
					b=b<=255 and b or 255
					--hash=r/255//hash_agresiveness+((g/255//hash_agresiveness)<<10)+((b/255//hash_agresiveness)<<20)+((a/255//hash_agresiveness)<<30)
					hash=hash_agresiveness<0 and -lasthash or (r//1>>hash_agresiveness)+(g//1>>hash_agresiveness<<8)+(b//1>>hash_agresiveness<<16)+(a//1>>hash_agresiveness<<24)
					if hash~=lasthash then
						color(255*(r/255)^2.4,255*(g/255)^2.4,255*(b/255)^2.4,a)
						lasthash=hash
					end

					r,g,b=triangle[4],triangle[5],triangle[6]
					draw(x-r[1],y+r[2],x-g[1],y+g[2],x-b[1],y+b[2])
				end
			end,

			---@section KL_complex_shader
			KL_complex_shader=function(self,lights)
				local sacrifice,cam_pos,light_dis,halfway,cam_dis=sacrificial_vec,self.camera_position,newVec(),newVec(),newVec()
				local l_dis_mag,obstructed,normal,dot,lr,lg,lb,spec_intens,diff_intens,material,diffuse,specular,halfway_mag,spec,mid,halfway1,halfway2,halfway3,l_dis1,l_dis2,l_dis3

				--[[]]
				for index,light in next,lights do
					light.range=light.range or (10*light.strength^0.5)
					light.position[4]=1
					lr=light.r
					lg=light.g
					lb=light.b
					for index,object in next,self.objects do
						if object.position:subV3(light.position,sacrifice):magnitudeV3()<light.range then
							for index,triangle in ipairs(object.screen_triangles) do
								normal=triangle.normal
								mid=triangle.mid
								--mid:sub3(light.position,light_dis)
								--l_dis_mag=light_dis:magnitude3()
								--dot=light_dis:dot3(normal)
								l_dis1=mid[1]-light.position[1]
								l_dis2=mid[2]-light.position[2]
								l_dis3=mid[3]-light.position[3]
								dot=l_dis1*normal[1]+l_dis2*normal[2]+l_dis3*normal[3]
								l_dis_mag=(l_dis1*l_dis1+l_dis2*l_dis2+l_dis3*l_dis3)^0.5
								if dot>0 then
									obstructed=false
									for index,object in next,self.objects do
										if object~=triangle.object and object.matrix then
											--light_dis:unit3(ray_direction)
											ray_direction[1]=l_dis1/l_dis_mag
											ray_direction[2]=l_dis2/l_dis_mag
											ray_direction[3]=l_dis3/l_dis_mag
											ray_direction:setV4(quickVecMult(object.unrotate_matrix,ray_direction))
											ray_origin:setV4(quickVecMult(object.inverse_matrix,light.position,1))
											local distance=ray_against_recursive_boxes(object.model.bounding_boxes)
											if distance and distance<l_dis_mag then
												obstructed=true
												break
											end
										end
									end
									if not obstructed then
									--for i=1,profiler:reps(100000^1) do
										material=triangle.material
										diffuse=material.diffuse
										specular=material.specular

										--it's to the third power becaue
										--light is diminishing with square of the distance
										--but then dot is not 0-1 because l_dist is not normalized like normal
										--so one more divide, so one more power
										diff_intens=dot*light.strength/l_dis_mag^3

										--mid:sub3(cam_pos,cam_dis)
										--cam_dis:add3(light_dis,halfway)--halfway
										--halfway_mag=halfway:magnitude3()
										--spec=halfway:dot(normal)/halfway_mag
										halfway1=mid[1]-cam_pos[1]+l_dis1
										halfway2=mid[2]-cam_pos[2]+l_dis2
										halfway3=mid[3]-cam_pos[3]+l_dis3
										halfway_mag=(halfway1*halfway1+halfway2*halfway2+halfway3*halfway3)^0.5
										spec=(halfway1*normal[1]+halfway2*normal[2]+halfway3*normal[3])/halfway_mag
										spec_intens=light.strength*spec^material.specular_exponent/l_dis_mag^2

										triangle.r=triangle.r+lr*(diff_intens*diffuse[1]+spec_intens*specular[1])
										triangle.g=triangle.g+lg*(diff_intens*diffuse[2]+spec_intens*specular[2])
										triangle.b=triangle.b+lb*(diff_intens*diffuse[3]+spec_intens*specular[3])
									--end
									--profiler:stop('lighting')
									end
								end
							end
						end
					end
				end
			end,
			---@endsection

			---@section KL_simple_shader
			KL_simple_shader=function(self,strength,decay)
				local min,distance,camera,dis_mag,dot,intensity=math.min,sacrificial_vec,self.camera_position
				for index,triangle in ipairs(self.screen_triangles) do
					triangle.mid:subV3(camera,distance)
					dis_mag=distance:magnitudeV3()
					dot=distance:dotV3(triangle.normal)
					intensity=dot<0 and 0 or strength*dot/dis_mag^decay
					triangle.r,triangle.g,triangle.b=min(255,intensity*triangle.material.diffuse[1]),min(255,intensity*triangle.material.diffuse[2]),min(255,intensity*triangle.material.diffuse[3])
				end
			end,
			---@endsection
		}
	end,
	---@endsection KL_RENDERCLASS
}
---@endsection KL_GRAPHICACLASS