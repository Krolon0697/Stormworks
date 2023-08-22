
---@section Matrix 1 MATRIXCLASS
Krolony.Math.Matrix=
{
	---@section newM
	---@param ... table multiple tables as parameters, each one being a single row
	---@return table object with methods
	newM=function(...)
		local matrix={...}
		for i,v in pairs(Krolony.Math.Matrix) do
			matrix[i]=v
		end
		return matrix
	end,
	---@endsection

	---@section copyM
	---@param A table matrix
	---@return table object with methods
	copyM=function(A)
		local t={}
		for i=1,#A do
			t[i]={table.unpack(A[i])}
		end
		return Krolony.Math.Matrix.newM(table.unpack(t))
	end,
	---@endsection

	---@section verifySquareM
	---true for square matrices
	---@param A table matrix
	---@return boolean
	verifySquareM=function(A)
		return #A==#A[1]
	end,
	---@endsection

	---@section addM
	---@param A table matrix
	---@param B table matrix
	---@param subtract boolean flag for subtracting
	---@return table object with methods
	addM=function (A,B,subtract)
		local t,mult=A:copyM(),subtract and -1 or 1
		for i=1,math.max(#t,#B) do
			t[i]=t[i] or {}
			for j=1,math.max(#t[1],#B[1]) do
				t[i][j]=((t[i] or {})[j] or (i==j and 1 or 0))+((B[i] or {})[j] or (i==j and 1 or 0))*mult
			end
		end
		return t
	end,
	---@endsection

	---@section scaleM
	---@param A table matrix
	---@param scaleBy number
	---@return table object with methods
	scaleM=function(A,scaleBy)
		local t=A:copyM()
		for i=1,#t do
			for j=1,#t[1] do
				t[i][j]=t[i][j]*scaleBy
			end
		end
		return t
	end,
	---@endsection

	---@section transposeM
	---@param A table matrix
	---@return table object with methods
	transposeM=function(A)
		local t,s={},#A
		for i=1,#A[1] do
			t[i]={}
			for j=1,s do
				t[i][j]=A[j][i]
			end
		end
		return Krolony.Math.Matrix.newM(table.unpack(t))
	end,
	---@endsection

	---@section multiplyM
	---@param A table matrix
	---@param B table matrix
	---@return table object with methods
	multiplyM=function (A,B)
		local t,s,v={},#B
		if #A[1]~=s then return end
		for i=1,#A do
			t[i]={}
			for j=1,#B[1] do
				v=0
				for k=1,s do
					v=v+A[i][k]*B[k][j]
				end
				t[i][j]=v
			end
		end
		return Krolony.Math.Matrix.newM(table.unpack(t))
	end,
	---@endsection

	---@section detM
	---@param A table matrix
	---@return number
	detM=function(A)
		local size,sum,mathing,t,v=#A,0,Krolony.Math.Matrix,{}
		if not mathing.verifySquareM(A) then return sum end
		if size==2 then
			return A[1][1]*A[2][2]-A[1][2]*A[2][1]
		elseif size>2 then
			for i=1,size-1 do
				t[i]={}
			end
			for i=1,size do
				v=(-1)^(size+i)*A[size][i]
				if v~=0 then
					for j=1,size-1 do
						for k=1,i-1 do
							t[j][k]=A[j][k]
						end
						for k=i,size do
							t[j][k]=A[j][k+1]
						end
					end
					v=v*mathing.detM(t)
					sum=sum+v
				end
			end
			return sum
		end
		return A[1][1]
	end,
	---@endsection

	---@section multVecM
	---multiplies matrix with a vector to produce new vector. returns x,y,z,w, do with it what you please, it doesn't enforce a vector output
	---@param mat table matrix
	---@param vec table vector
	---@return number x
	---@return number y
	---@return number z
	---@return number w
	multVecM=function(mat,vec)
		local t,c,s,v={},{vec.x,vec.y,vec.z or 0, vec.w or 0},#mat[1]
		for i=1,#mat do
			--v=mat[i][1]*vec.x+mat[i][2]*vec.y+(vec.z and mat[i][3]*vec.z or 0)+(vec.w and mat[i][4]*vec.w or 0)
			v=0
			for j=1,s do
				v=v+mat[i][j]*c[j]
			end
			t[i]=v
		end
		return t[1],t[2],t[3],t[4]
	end,
	---@endsection

	---@section vectorToMatrix
	---changes Krolony.Vector into Krolony.Math.Matrix vector form
	---@param vec table vector
	---@return table object with methods
	vectorToMatrix=function(vec)
		return Krolony.Math.Matrix.newM({vec.x},{vec.y},vec.z and {vec.z},vec.w and {vec.w})
	end,
	---@endsection

	---@section matrixToVector3
	---changes Krolony.Matrix into Krolony.Math.Vec3
	---@param A table matrix
	---@return table object with methods
	matrixToVector3=function(A)
		return Krolony.Math.Vec3.newM(A[1][1],A[2][1],A[3][1],(A[4] or {})[1])
	end,
	---@endsection

	---@section matrixToVector2
	---changes Krolony.Matrix into Krolony.Math.Vec3
	---@param A table vector
	---@return table object with methods
	matrixToVector2=function(A)
		return Krolony.Math.Vec2.newM(A[1][1],A[2][1])
	end,
	---@endsection

	---@section cofactorM
	---@param A table matrix
	---@return table matrix
	cofactorM=function(A)
		if not A:verifySquareM() then return A:copyM() end
		local t2,t={}
		for i=1,#A do
			t2[i]={}
			for j=1,#A[1] do
				t={}
				for n=1,#A-1 do
					t[n]={}
					for m=1,#A[1]-1 do
						t[n][m]=A[n+(n>=i and 1 or 0)][m+(m>=j and 1 or 0)]
					end
				end
				t=Krolony.Math.Matrix.newM(table.unpack(t))
				t2[i][j]=t:detM()*(-1)^(i+j)
			end
		end
		return Krolony.Math.Matrix.newM(table.unpack(t2))
	end,
	---@endsection

	---@section inverseM
	---very bad, but works
	---@param A table matrix
	---@return table matrix
	inverseM=function(A)
		if not A:verifySquareM() or A:detM()==0 then return A:copyM() end
		local t=A:cofactorM()
		t=t:transposeM()
		t=t:scaleM(1/A:detM())
		return t--((A:cofactorM()):transposeM()):scaleM(1/A:detM())
	end,
	---@endsection

	---@section identityM
	---@param size integer return an size x size identity matrix
	---@return table object with methods
	identityM=function(size)
		local t={}
		for i=1,size do
			t[i]={}
			for j=1,size do
				t[i][j]=i==j and 1 or 0
			end
		end
		return Krolony.Math.Matrix.newM(table.unpack(t))
	end,
	---@endsection

--[[
	---@section getMatrix
	---made by quale, that's so yikes I couldn't do it myself, roll tilt sensor facing to the right, pitch tilt sensor facing to the front, upright tilt sensor facing up, compass sensor facing the direction of motion
	getMatrix=function(roll,pitch,upright,compass)
		local x,y,z,a,c,s,m=math.sin(2*math.pi*roll),math.sin(2*math.pi*pitch),sin(2*math.pi*upright),2*math.pi*compass
		m=(x*x+z*z)^0.5
		m={z/m,0,-x/m;-y*x/m,m,-y*z/m;x,y,z}
		c=cos(a)
		s=sin(a)
		for j=1,3 do m[j],m[j+3]=c*m[j]-s*m[j+3],s*m[j]+c*m[j+3]end
		return m
	end,
	--get a matrix of the vessel orientation, x/right, y/forward, z/up
	---@endsection

	---@section vehicleToWorld
	---change vehicle relative XYZ to world relative XYZ, unadjusted for vehicle position, xy map z alt
	vehicleToWorld=function(x,y,z,matrix)
		return matrix[1]*x+matrix[2]*y+matrix[3]*z,matrix[4]*x+matrix[5]*y+matrix[6]*z,matrix[7]*x+matrix[8]*y+matrix[9]*z
	end,
	---@endsection

	---@section worldToVehicle
	---change world relative XYZ to vehicle relative XYZ, unadjusted for vehicle position, xy map z alt
	worldToVehicle=function(x,y,z,matrix)
		return matrix[1]*x+matrix[4]*y+matrix[7]*z,matrix[2]*x+matrix[5]*y+matrix[8]*z,matrix[3]*x+matrix[6]*y+matrix[9]*z
	end,
	---@endsection
	]]

}
---@endsection MATRIXCLASS