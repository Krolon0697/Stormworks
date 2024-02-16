
---@section Vec2 1 VECTOR2CLASS
Krolony.Math.Vec2=--2D
{
	---@param x number initial position, defaults to 0
	---@param y number initial position, defaults to 0
	---@return table object with methods
	newV2=function(x,y)
		local t={x=x or 0,y=y or 0,vectorToMatrix=Krolony.Math.Matrix.vectorToMatrix}
		for i,v in pairs(Krolony.Math.Vec2) do
			t[i]=v
		end
		return t
	end,

	---@section setV2
	---sets x and y to different place
	---@param A table
	---@param x number
	---@param y number
	setV2=function(A,x,y)
		A.x=x
		A.y=y
	end,
	---@endsection

	---@section dotV2
	---dot product
	---@param A table
	---@param B table vector
	---@return number dot
	dotV2=function(A,B)
		return A.x*B.x+A.y*B.y
	end,
	---@endsection

	---@section magnitudeV2
	---@param A table
	---@return number magnitude
	magnitudeV2=function(A)
		return (A.x*A.x+A.y*A.y)^0.5
	end,
	---@endsection

	---@section anglePointsV2
	---angle at which A is in regards to B in polar coordinates. Or math coordinates. Aaaaaaa
	---@param A table
	---@param B table vector
	---@return number angle radians
	anglePointsV2=function(A,B)
		return math.atan(A.y-B.y,A.x-B.x)
	end,
	---@endsection

	---@section angleV2
	---angle between 2 vectors
	---@param A table
	---@param B table
	---@return number angle radians
	angleV2=function(A,B)
		return math.atan(A.y*B.x-A.x*B.y,A.x*B.x+A.y*B.y)
	end,
	---@endsection

	---@section addV2
	---@param A table
	---@param B table vector
	---@param out table
	---@return table object with methods
	addV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		out:setV2(A.x+B.x,A.y+B.y)
		return out
	end,
	---@endsection

	---@section subV2
	---@param A table
	---@param B table
	---@param out table
	---@return table object with methods
	subV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		out:setV2(A.x-B.x,A.y-B.y)
		return out
	end,
	---@endsection

	---@section scaleV2
	---@param A table
	---@param B number to scale by
	---@param out table
	---@return table object with methods
	scaleV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		out:setV2(A.x*B,A.y*B)
		return out
	end,
	---@endsection

	---@section unitV2
	---@param A table
	---@param out table
	---@return table object with methods
	unitV2=function(A,out)
		out=out or Krolony.Math.Vec2.newV2()
		local mag=A:MagnitudeV2()
		out:setV2(A.x/mag,A.y/mag)
		return out
	end,
	---@endsection

	---@section rotV2
	---rotates point A around point B
	---@param A table
	---@param B table vector
	---@param angle number radians
	---@param out table
	---@param setFlag boolean specify whether it's set to be at specific angle (true) or rotated by angle (false)
	---@return table object with methods
	rotV2=function(A,B,angle,out,setFlag)
		out=out or Krolony.Math.Vec2.newV2()
		local l,a=((A.x-B.x)^2+(A.y-B.y)^2)^0.5,setFlag and angle or angle+math.atan(A.y-B.y,A.x-B.x)
		out:setV2(B.x+l*math.cos(a),B.y+l*math.sin(a))
		return out
	end,
	---@endsection

	---@section scalarProjectV2
	---ngl I don't even fucking know what this is but it scalarly projects A onto B whatever that means
	---@param A table vector
	---@param B table vector
	---@param out table
	---@return number
	scalarProjectV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		out=B:unitV2(out)
		return A:dotV2(out)
	end,
	---@endsection

	---@section projectV2
	---project A onto B
	---@param A table vector
	---@param B table vector
	---@param out table
	---@return table object with methods
	projectV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		return B:scaleV2(A:dotV2(B)/B:dotV2(B),out)
	end,
	---@endsection

	---@section rejectV2
	---reject A from B
	---@param A table vector
	---@param B table vector
	---@param out table
	---@return table object with methods
	rejectV2=function(A,B,out)
		out=out or Krolony.Math.Vec2.newV2()
		A:ProjectV2(B,out)
		return A:suV2b(out,out)
	end
	---@endsection
}
---@endsection VECTOR2CLASS

---@section Vec3 1 VECTOR3CLASS
Krolony.Math.Vec3=--3D
{
	---@section newV3
	---@param x number initial position, defaults to 0
	---@param y number initial position, defaults to 0
	---@param z number initial position, defaults to 0
	---@param w number initial position, defaults to 0, useful for weird 4D shit in 3D
	---@return table object with methods
	newV3=function(x,y,z,w)
		local t={x=x or 0,y=y or 0,z=z or 0,w=w or 1}
		for i,v in next,Krolony.Math.Vec3 do
			t[i]=v
		end
		return t
	end,
	---@endsection

	---@section setV3
	---sets xyz to different place
	---@param A table
	---@param x number default to nil
	---@param y number defaults to nil
	---@param z number defaults to nil
	---@param w any defaults to nil
	setV3=function(A,x,y,z,w)
		A.x=x
		A.y=y
		A.z=z
		A.w=w or 1
	end,

	---@endsection
	---@section setToV3
	---sets xyz to different place
	---@param A table vector to set
	---@param B table vector from which to set
	setToV3=function(A,B)
		A.x=B.x
		A.y=B.y
		A.z=B.z
		A.w=B.w or 1
	end,
	---@endsection

	---@section dotV3
	---dot product of 2 vectors
	---@param A table
	---@param B table vector
	---@return number dot
	dotV3=function(A,B)
		return A.x*B.x+A.y*B.y+A.z*B.z+A.w*B.w
	end,
	---@endsection

	---@section magnitudeV3
	---@param A table
	---@return number magnitude
	magnitudeV3=function(A)
		return (A.x*A.x+A.y*A.y+A.z*A.z)^0.5
	end,
	---@endsection

	---@section angleV3
	---angle between 2 vectors
	---@param A table
	---@param B table vectors
	---@return number angle in radians
	angleV3=function(A,B)
		return math.acos(Krolony.Utilities.clamp(-1,1,A:dotV3(B)/(A:magnitudeV3()*B:magnitudeV3())))
	end,
	---@endsection

	---@section addV3
	---@param A table
	---@param B table vector
	---@return table object with methods
	addV3=function(A,B,out)
		out=out or Krolony.Math.Vec3.newV3()
		out:setV3(A.x+B.x,A.y+B.y,A.z+B.z,A.w+B.w)
		return out
	end,
	---@endsection

	---@section subV3
	---@param A table
	---@param B table vector
	---@return table object with methods
	subV3=function(A,B,out)
		out=out or Krolony.Math.Vec3.newV3()
		out:setV3(A.x-B.x,A.y-B.y,A.z-B.z,A.w-B.w)
		return out
	end,
	---@endsection

	---@section scaleV3
	---@param A table
	---@param ScaleBy number
	---@return table object with methods
	scaleV3=function(A,ScaleBy,out)
		out=out or Krolony.Math.Vec3.newV3()
		out:setV3(A.x*ScaleBy,A.y*ScaleBy,A.z*ScaleBy,A.w*ScaleBy)
		return out
	end,
	---@endsection

	---@section unitV3
	---unit vector (magnitude of 1) in the same direction as A
	---@param A table
	---@return table object with methods
	unitV3=function(A,out)
		out=out or Krolony.Math.Vec3.NewV3()
		return A:scaleV3(1/A:magnitudeV3(),out)
	end,
	---@endsection

	---@section crossV3
	---cross product of 2 vectors, only in 3D
	---@param A table vector
	---@param B table vector
	---@return table object with methods
	crossV3=function(A,B,out)
		out=out or Krolony.Math.Vec3.newV3()
		out:setV3(A.y*B.z-A.z*B.y,A.z*B.x-A.x*B.z,A.x*B.y-A.y*B.x)
		return out
	end,
	---@endsection
	
	---@section vectorToMatrix
	---changes Krolony.Vector into Krolony.Math.Matrix vector form
	---@param vec table vector
	---@return table object with methods
	vectorToMatrix=function(vec)
		return Krolony.Math.Matrix.newM({vec.x},{vec.y},{vec.z},vec.w and {vec.w})
	end,
	---@endsection

	---@section projectV3
	---projects A onto B
	---@param A table vector
	---@param B table vector
	---@return table object with methods
	projectV3=function(A,B,out)
		return B:scaleV3(A:dotV3(B)/B:dotV3(B),out)
	end,
	---@endsection

	---@section rejectV3
	---rejects A from B
	---@param A table vector
	---@param B table vector
	---@return table object with methods
	rejectV3=function(A,B,out)
		return A:subV3(Krolony.Math.Vec3.projectV3(A,B,out),out)
	end
	---@endsection
}
---@endsection VECTOR3CLASS