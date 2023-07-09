---@section Vectors 1 VECTORCLASS
Krolony.Vectors={
	---@section Vector2 1 VECTOR2CLASS
	Vector2=--2D
	{
		---@param x number initial position, defaults to 0
		---@param y number initial position, defaults to 0
		---@return table object with methods
		new=function(x,y) return {x=x or 0,y=y or 0,
			---sets x and y to different place
			---@param self table
			---@param x number
			---@param y number
			set=function(self,x,y)
				self.x=x
				self.y=y
			end,

			---@section dot
			---dot product
			---@param self table
			---@param B table vector
			---@return number dot
			dot=function(self,B)
				return self.x*B.x+self.y*B.y
			end,
			---@endsection

			---@section magnitude
			---@param self table
			---@return number magnitude
			magnitude=function(self)
				return (self.x*self.x+self.y*self.y)^0.5
			end,
			---@endsection

			---@section anglePoints
			---angle at which self is in regards to B
			---@param self table
			---@param B table vector
			---@return number angle radians
			anglePoints=function(self,B)
				return math.atan(self.y-B.y,self.x-B.x)
			end,
			---@endsection

			---@section angle
			---angle between 2 vectors
			---@param self table
			---@param B table
			---@return number angle radians
			angle=function(self,B)
				return math.atan(self.y*B.x-self.x*B.y,self.x*B.x+self.y*B.y)
			end,
			---@endsectios

			---@section add
			---usage vector:set(vector:add(vector)) or just new(vector:add(vector))
			---@param self table
			---@param B table vector
			---@return number x
			---@return number y
			add=function(self,B)
				return self.x+B.x,self.y+B.y
			end,
			---@endsection

			---@section sub
			---usage vector:set(vector:sub(vector)) or just new(vector:sub(vector))
			---@param self table
			---@param B table
			---@return number x
			---@return number y
			sub=function(self,B)
				return self.x-B.x,self.y-B.y
			end,
			---@endsection

			---@section scale
			---scales vector, usage vector:set(vector:scale(vector)) or just new(vector:scale(vector))
			---@param self table
			---@param B number to scale by
			---@return number x
			---@return number y
			scale=function(self,B)
				return self.x*B,self.y*B
			end,
			---@endsection

			---@section unit
			---unit vector in same orientation, usage vector:set(vector:unit(vector)) or just new(vector:unit(vector))
			---@param self table
			---@return number x
			---@return number y
			unit=function(self)
				return self:scale(1/self:Magnitude())
			end,
			---@endsection

			---@section rot
			---rotates vector around vector B, usage vector:set(vector:rot(vector)) or just new(vector:rot(vector))
			---@param self table
			---@param B table vector
			---@param angle number radians
			---@param setFlag boolean specify whether it's set to be at specific angle (true) or rotated by angle (false)
			---@return number x
			---@return number y
			rot=function(self,B,angle,setFlag)
				local l,a=((self.x-B.x)^2+(self.y-B.y)^2)^0.5,setFlag and angle or angle+math.atan(self.y-B.y,self.x-B.x)
				return B.x+l*math.cos(a),B.y+l*math.sin(a)
			end,
			---@endsection

		}
		end,

		---@section scalarProject
		---ngl I don't even fucking know what this is but it scalarly projects A onto B whatever that means
		---@param A table vector
		---@param B table vector
		---@return number
		scalarProject=function(A,B)return A:dot(Krolony.Vectors.Vector2.new(B:unit())) end,
		---@endsection

		---@section project
		---project A onto B
		---@param A table vector
		---@param B table vector
		---@return number x
		---@return number y
		project=function(A,B)return B:scale(A:dot(B)/B:dot(B))end,
		---@endsection

		---@section reject
		---reject A from B
		---@param A table vector
		---@param B table vector
		---@return number x
		---@return number y
		reject=function(A,B)return A:sub(Krolony.Vectors.Vector2.Project(A,B)) end
		---@endsetion
	},
	---@endsection VECTOR2CLASS

	---@section Vector3 1 VECTOR3CLASS
	Vector3=--3D
	{
		---@section New
		---@param x number initial position, defaults to 0
		---@param y number initial position, defaults to 0
		---@param z number initial position, defaults to 0
		---@return table object with methods
		New=function(x,y,z) return {x=x or 0,y=y or 0,z=z or 0,
			---sets x and y to different place
			---@param self table
			---@param x number
			---@param y number
			---@param z number
			Set=function(self,x,y,z)
				self.x=x
				self.y=y
				self.z=z
			end,

			---@section Dot
			---dot product of 2 vectors
			---@param self table
			---@param B table vector
			---@return number dot
			Dot=function(self,B)
				return self.x*B.x+self.y*B.y+self.z*B.z
			end,
			---@endsection

			---@section Magnitude
			---@param self table
			---@return number magnitude
			Magnitude=function(self)
				return (self.x*self.x+self.y*self.y+self.z*self.z)^0.5
			end,
			---@endsection

			---@section Angle
			---angle between 2 vectors
			---@param self table
			---@param B table vectors
			---@return number angle in radians
			Angle=function(self,B)
				return math.acos(Krolony.Utilities.clamp(-1,1,self:dot(B)/(self:Magnitude()*B:Magnitude())))
			end,
			---@endsection Angle

			---@section Add
			---usage vector:set(vector:add(vector)) or just new(vector:add(vector))
			---@param self table
			---@param B table vector
			---@return number x
			---@return number y
			---@return number z
			Add=function(self,B)
				return self.x+B.x,self.y+B.y,self.z+B.z
			end,
			---@endsection

			---@section Sub
			---usage vector:set(vector:Sub(vector)) or just new(vector:Sub(vector))
			---@param self table
			---@param B table vector
			---@return number x
			---@return number y
			---@return number z
			Sub=function (self,B)
				return self.x-B.x,self.y-B.y,self.z-B.z
			end,
			---@endsection

			---@section Scale
			---usage vector:set(vector:scale(vector)) or just new(vector:scale(vector))
			---@param self table
			---@param B table vector
			---@return number x
			---@return number y
			---@return number z
			Scale=function(self,B)
				return self.x*B,self.y*B,self.z*B
			end,
			---@endsection

			---@section Unit
			---usage vector:set(vector:Unit(vector)) or just new(vector:Unit(vector))
			---@param self table
			---@return number x
			---@return number y
			---@return number z
			Unit=function(self)
				return self:scale(1/self:Magnitude())
			end,
			---@endsection
		}
		end,
	---@endsection

	---@section Cross
	---cross product of 2 vectors, usage vector:set(cross(vector,vector)) or just new(cross(vector,vector))
	---@param A table vector
	---@param B table vector
	---@return number x
	---@return number y
	---@return number z
		Cross=function(A,B)return A.y*B.z-A.z*B.y,A.z*B.x-A.x*B.z,A.x*B.y-A.y*B.x end,
	---@endsection

	---@section Project
	---projects A onto B, usage vector:set(project(vector,vector)) or just new(project(vector,vector))
	---@param A table vector
	---@param B table vector
	---@return number x
	---@return number y
	---@return number z
		Project=function(A,B)return B:Scale(A:Dot(B)/B:Dot(B))end,
	---@endsection

	---@section Reject
	---rejects A from B
	---@param A table vector
	---@param B table vector
	---@return number x
	---@return number y
	---@return number z
		Reject=function(A,B)return A:Sub(Krolony.Vectors.Vector3.New(Krolony.Vectors.Vector3.Project(A,B))) end
	---@endsection
	},
	---@endsection VECTOR3CLASS
}
---@endsection VECTORCLASS