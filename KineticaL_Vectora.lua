
---@section __LB_SIMULATOR_ONLY_KINETICAL_VECTORA__
local KineticaL,KL_ipairs,KL_pairs,KL_insert,KL_remove,KL_type=KineticaL,ipairs,pairs,table.insert,table.remove,type
---@endsection

---@section KL_Vectora 1 KL_VECTORACLASS
---Very fast vectors, slow declaration but enforces the use of efficient methods. Has dedicated function for 2D, 3D, 4D and arbitrary size vectors.
KineticaL.KL_Vectora={

	---@section KL_newVA
	---@return table object
	KL_newVA=function(...)
		local vec={...}

		if KL_type(vec[1])=='table' then KL_remove(vec,1) end
		if #vec==1 then
			for i=1,vec[1] do
				vec[i]=0
			end
		end

		for i,v in KL_pairs(KineticaL.KL_Vectora) do
			vec[i]=v
		end
		return vec
	end,
	---@endsection

	---@section KL_setV2
	---sets xy to different place
	---@param out table
	---@param x number default to nil
	---@param y number defaults to nil
	KL_setV2=function(out,x,y)
		out[1]=x
		out[2]=y
		return out
	end,
	---@endsection

	---@section KL_setV3
	---sets xyz to different place
	---@param out table
	---@param x number default to nil
	---@param y number defaults to nil
	---@param z number defaults to nil
	KL_setV3=function(out,x,y,z)
		out[1]=x
		out[2]=y
		out[3]=z
		return out
	end,
	---@endsection

	---@section KL_setV4
	---sets xyzw to different place
	---@param out table
	---@param x number default to nil
	---@param y number defaults to nil
	---@param z number defaults to nil
	---@param w number|nil defaults to 1
	KL_setV4=function(out,x,y,z,w)
		out[1]=x
		out[2]=y
		out[3]=z
		out[4]=w or 1
		return out
	end,
	---@endsection

	---@section KL_setVA
	---sets xyzw to different place
	---@param out table
	---@param ... number
	KL_setVA=function(out,...)
		out:KL_setToVA({...})
		return out
	end,
	---@endsection

	---@section KL_setToV2
	---sets xyz to be same as different vector
	---@param out table to set
	---@param A table from which to set
	KL_setToV2=function(out,A)
		out:KL_setV2(A[1],A[2],A[3],A[4])
		return out
	end,
	---@endsection

	---@section KL_setToV3
	---sets xyz to be same as different vector
	---@param out table to set
	---@param A table from which to set
	KL_setToV3=function(out,A)
		out:KL_setV3(A[1],A[2],A[3],A[4])
		return out
	end,
	---@endsection

	---@section KL_setToV4
	---sets xyz to be same as different vector
	---@param out table to set
	---@param A table from which to set
	KL_setToV4=function(out,A)
		out:KL_setV4(A[1],A[2],A[3],A[4])
		return out
	end,
	---@endsection

	---@section KL_setToVA
	---sets xyz to be same as different vector
	---@param out table to set
	---@param A table from which to set
	KL_setToVA=function(out,A)
		for i,v in KL_ipairs(A) do
			out[i]=v
		end
		return out:KL_pruneVA(#A)
	end,
	---@endsection

	---@section KL_pruneVA
	KL_pruneVA=function(out,size)
		for i=#out,size+1,-1 do
			KL_remove(out,i)
		end
		return out
	end,
	---@endsection

	---@section KL_copyV2
	---sets xyz to be same as different vector
	---@param A table
	---@return table
	KL_copyV2=function(A)
		return A.KL_newVA(A[1],A[2])
	end,
	---@endsection

	---@section KL_copyV3
	---sets xyz to be same as different vector
	---@param A table
	---@return table
	KL_copyV3=function(A)
		return A.KL_newVA(A[1],A[2],A[3])
	end,
	---@endsection

	---@section KL_copyV4
	---sets xyz to be same as different vector
	---@param A table
	---@return table
	KL_copyV4=function(A)
		return A.KL_newVA(A[1],A[2],A[3],A[4])
	end,
	---@endsection

	---@section KL_copyVA
	---sets xyz to be same as different vector
	---@param A table
	---@return table
	KL_copyVA=function(A)
		local out=A.KL_newVA()
		for i=1,#A do
			out[i]=A[i]
		end
		return out
	end,
	---@endsection

	---@section KL_dotV2
	---dot product of 2 vectors
	---@param A table
	---@param B table
	---@return number dot
	KL_dotV2=function(A,B)
		return A[1]*B[1]+A[2]*B[2]
	end,
	---@endsection

	---@section KL_dotV3
	---dot product of 2 vectors
	---@param A table
	---@param B table
	---@return number dot
	KL_dotV3=function(A,B)
		return A[1]*B[1]+A[2]*B[2]+A[3]*B[3]
	end,
	---@endsection

	---@section KL_dotV4
	---dot product of 2 vectors
	---@param A table
	---@param B table
	---@return number dot
	KL_dotV4=function(A,B)
		return A[1]*B[1]+A[2]*B[2]+A[3]*B[3]+A[4]*B[4]
	end,
	---@endsection

	---@section KL_dotVA
	---dot product of 2 vectors
	---@param A table
	---@param B table
	---@return number dot
	KL_dotVA=function(A,B)
		local dot=0
		for i,v in KL_ipairs(A) do
			dot=dot+v*(B[i] or 0)
		end
		return dot
	end,
	---@endsection

	---@section KL_magnitudeV2
	---@param A table
	---@return number magnitude
	KL_magnitudeV2=function(A)
		return (A[1]*A[1]+A[2]*A[2])^0.5
	end,
	---@endsection

	---@section KL_magnitudeV3
	---@param A table
	---@return number magnitude
	KL_magnitudeV3=function(A)
		return (A[1]*A[1]+A[2]*A[2]+A[3]*A[3])^0.5
	end,
	---@endsection

	---@section KL_magnitudeV4
	---@param A table
	---@return number magnitude
	KL_magnitudeV4=function(A)
		return (A[1]*A[1]+A[2]*A[2]+A[3]*A[3]+A[4]*A[4])^0.5
	end,
	---@endsection

	---@section KL_magnitudeVA
	---@param A table
	---@return number magnitude
	KL_magnitudeVA=function(A)
		local mag=0
		for i,v in KL_ipairs(A) do
			mag=mag+v*v
		end
		return mag^0.5
	end,
	---@endsection

	---@section KL_angleVA
	---angle between 2 vectors
	---@param A table
	---@param B table
	---@return number angle in radians
	KL_angleVA=function(A,B)
		return math.acos(KineticaL.KL_clamp(-1,1,A:KL_dotVA(B)/(A:KL_magnitudeVA()*B:KL_magnitudeVA())))
	end,
	---@endsection

	---@section KL_angleV2
	---Optimized for 2 dimensions. angle between 2 vectors
	---@param A table
	---@param B table
	---@return number angle radians
	KL_angleV2=function(A,B)
		return math.atan(A[2]*B[1]-A[1]*B[2],A[1]*B[1]+A[2]*B[2])
	end,
	---@endsection

	---@section KL_anglePointsV2
	---only 2 dimensions, angle at which A is in regards to B in polar coordinates. Or math coordinates. Aaaaaaa
	---@param A table
	---@param B table
	---@return number angle radians
	KL_anglePointsV2=function(A,B)
		return math.atan(A[2]-B[2],A[1]-B[1])
	end,
	---@endsection

	---@section KL_rotV2
	---Only 2 dimensions. rotates point A around point B
	---@param out table
	---@param A table
	---@param B table
	---@param angle number radians
	---@param setFlag boolean specify whether it's set to be at specific angle (true) or rotated by angle (false)
	KL_rotV2=function(out,A,B,angle,setFlag)
		local l,a=((A[1]-B[1])^2+(A[2]-B[2])^2)^0.5,setFlag and angle or angle+math.atan(A[2]-B[2],A[1]-B[1])
		out:KL_setV2(B[1]+l*math.cos(a),B[2]+l*math.sin(a))
		return out
	end,
	---@endsection

	---@section KL_addV2
	---@param out table
	---@param A table
	---@param B table
	KL_addV2=function(out,A,B)
		out:KL_setV2(A[1]+B[1],A[2]+B[2])
		return out
	end,
	---@endsection

	---@section KL_addV3
	---@param out table
	---@param A table
	---@param B table
	KL_addV3=function(out,A,B)
		out:KL_setV3(A[1]+B[1],A[2]+B[2],A[3]+B[3])
		return out
	end,
	---@endsection

	---@section KL_addV4
	---@param out table
	---@param A table
	---@param B table
	KL_addV4=function(out,A,B)
		out:KL_setV4(A[1]+B[1],A[2]+B[2],A[3]+B[3],A[4]+B[4])
		return out
	end,
	---@endsection

	---@section KL_addVA
	---@param out table
	---@param A table is dominant over B in regards to the output size
	---@param B table
	KL_addVA=function(out,A,B)
		for i,v in KL_ipairs(A) do
			out[i]=v+(B[i] or 0)
		end
		return out:KL_pruneVA(#A)
	end,
	---@endsection

	---@section KL_subV2
	---@param A table
	---@param B table
	KL_subV2=function(out,A,B)
		out:KL_setV2(A[1]-B[1],A[2]-B[2])
		return out
	end,
	---@endsection

	---@section KL_subV3
	---@param out table
	---@param A table
	---@param B table
	KL_subV3=function(out,A,B)
		out:KL_setV3(A[1]-B[1],A[2]-B[2],A[3]-B[3])
		return out
	end,
	---@endsection

	---@section KL_subV4
	---@param out table
	---@param A table
	---@param B table
	KL_subV4=function(out,A,B)
		out:KL_setV4(A[1]-B[1],A[2]-B[2],A[3]-B[3],A[4]-B[4])
		return out
	end,
	---@endsection

	---@section KL_subVA
	---@param out table
	---@param A table is dominant over B in regards to the output size
	---@param B table
	KL_subVA=function(out,A,B)
		for i,v in KL_ipairs(A) do
			out[i]=v-(B[i] or 0)
		end
		return out:KL_pruneVA(#A)
	end,
	---@endsection

	---@section KL_addMultV2
	---@param out table
	---@param A table
	---@param B table
	---@param mult number 
	KL_addMultV2=function(out,A,B,mult)
		out:KL_setV2(A[1]+B[1]*mult,A[2]+B[2]*mult)
		return out
	end,
	---@endsection

	---@section KL_addMultV3
	---@param out table
	---@param A table
	---@param B table
	---@param mult number 
	KL_addMultV3=function(out,A,B,mult)
		out:KL_setV3(A[1]+B[1]*mult,A[2]+B[2]*mult,A[3]+B[3]*mult)
		return out
	end,
	---@endsection

	---@section KL_addMultV4
	---@param out table
	---@param A table
	---@param B table
	---@param mult number 
	KL_addMultV4=function(out,A,B,mult)
		out:KL_setV4(A[1]+B[1]*mult,A[2]+B[2]*mult,A[3]+B[3]*mult,A[4]+B[4]*mult)
		return out
	end,
	---@endsection

	---@section KL_addMultVA
	---@param out table
	---@param A table is dominant over B in regards to the output size
	---@param B table
	---@param mult number 
	KL_addMultVA=function(out,A,B,mult)
		for i,v in KL_ipairs(A) do
			out[i]=v+(B[i] or 0)*mult
		end
		return out:KL_pruneVA(#A)
	end,
	---@endsection

	---@section KL_scaleV2
	---@param out table
	---@param A table
	---@param ScaleBy number
	KL_scaleV2=function(out,A,ScaleBy)
		out:KL_setV2(A[1]*ScaleBy,A[2]*ScaleBy)
		return out
	end,
	---@endsection

	---@section KL_scaleV3
	---@param out table
	---@param A table
	---@param ScaleBy number
	KL_scaleV3=function(out,A,ScaleBy)
		out:KL_setV3(A[1]*ScaleBy,A[2]*ScaleBy,A[3]*ScaleBy)
		return out
	end,
	---@endsection

	---@section KL_scaleV4
	---@param out table
	---@param A table
	---@param ScaleBy number
	KL_scaleV4=function(out,A,ScaleBy)
		out:KL_setV4(A[1]*ScaleBy,A[2]*ScaleBy,A[3]*ScaleBy,A[4]*ScaleBy)
		return out
	end,
	---@endsection

	---@section KL_scaleVA
	---@param out table
	---@param A table is dominant over B in regards to the output size
	---@param ScaleBy number
	KL_scaleVA=function(out,A,ScaleBy)
		for i,v in KL_ipairs(A) do
			out[i]=v*ScaleBy
		end
		return out:KL_pruneVA(#A)
	end,
	---@endsection

	---@section KL_unitV2
	---unit vector (magnitude of 1) in the same direction as A
	---@param out table
	---@param A table
	KL_unitV2=function(out,A)
		local mag=A:KL_magnitudeV2()
		out:KL_setV2(A[1]/mag,A[2]/mag)
		return out
	end,
	---@endsection

	---@section KL_unitV3
	---unit vector (magnitude of 1) in the same direction as A
	---@param out table
	---@param A table
	KL_unitV3=function(out,A)
		local mag=A:KL_magnitudeV3()
		out:KL_setV3(A[1]/mag,A[2]/mag,A[3]/mag)
		return out
	end,
	---@endsection

	---@section KL_unitV4
	---unit vector (magnitude of 1) in the same direction as A
	---@param out table
	---@param A table
	KL_unitV4=function(out,A)
		local mag=A:KL_magnitudeV4()
		out:KL_setV4(A[1]/mag,A[2]/mag,A[3]/mag,A[4]/mag)
		return out
	end,
	---@endsection

	---@section KL_unitVA
	---unit vector (magnitude of 1) in the same direction as A
	---@param out table
	---@param A table
	KL_unitVA=function(out,A)
		out:KL_setToVA(A)
		out:KL_scaleVA(out,1/out:KL_magnitudeVA())
		return out
	end,
	---@endsection

	---@section KL_crossV3
	---cross product of 2 vectors, only in 3D
	---@param out table
	---@param A table
	---@param B table
	KL_crossV3=function(out,A,B)
		out:KL_setV3(A[2]*B[3]-A[3]*B[2],A[3]*B[1]-A[1]*B[3],A[1]*B[2]-A[2]*B[1])
		return out
	end,
	---@endsection

	---@section KL_crossV2
	---cross product of 2 vectors in 2D, returns scalar equal to pararrelogram's area if made of those vectors, equal to Z component in 3D
	---@param A table
	---@param B table
	---@return number cross
	KL_crossV2=function(A,B)
		return A[1]*B[2]-A[2]*B[1]
	end,
	---@endsection

	---@section KL_projectV2
	---projects A onto B, output is in direction of B
	---@param out table
	---@param A table
	---@param B table
	KL_projectV2=function(out,A,B)
		local dotAB=A:KL_dotV2(B)--computed early in case A and out are same vector
		out:KL_setToV2(B)
		out:KL_scaleV2(out,dotAB/B:KL_dotV2(B))
		return out
	end,
	---@endsection

	---@section KL_projectV3
	---projects A onto B, output is in direction of B
	---@param out table
	---@param A table
	---@param B table
	KL_projectV3=function(out,A,B)
		local dotAB=A:KL_dotV3(B)--computed early in case A and out are same vector
		out:KL_setToV3(B)
		out:KL_scaleV3(out,dotAB/B:KL_dotV3(B))
		return out
	end,
	---@endsection

	---@section KL_projectV4
	---projects A onto B, output is in direction of B
	---@param out table
	---@param A table
	---@param B table
	KL_projectV4=function(out,A,B)
		local dotAB=A:KL_dotV4(B)--computed early in case A and out are same vector
		out:KL_setToV4(B)
		out:KL_scaleV4(out,dotAB/B:KL_dotV4(B))
		return out
	end,
	---@endsection

	---@section KL_projectVA
	---projects A onto B, output is in direction of B
	---@param out table
	---@param A table
	---@param B table is dominant over A in regards to the output dimensions
	KL_projectVA=function(out,A,B)
		local dotAB=A:KL_dotVA(B)--computed early in case A and out are same vector
		out:KL_setToVA(B)
		out:KL_scaleVA(out,dotAB/B:KL_dotVA(B))
		return out
	end,
	---@endsection

	---@section KL_rejectV2
	---rejects A from B, output is in direction A
	---@param out table
	---@param A table
	---@param B table
	KL_rejectV2=function(out,A,B)
		local locA=A
		if out==A then
			--safeguard for when A and out are the same vector
			locA=A:KL_copyV2()
		end
		out:KL_projectV2(locA,B)
		out:KL_subV2(locA,out)
		return out
	end,
	---@endsection

	---@section KL_rejectV3
	---rejects A from B, output is in direction A
	---@param out table
	---@param A table
	---@param B table
	KL_rejectV3=function(out,A,B)
		local locA=A
		if out==A then
			--safeguard for when A and out are the same vector
			locA=A.KL_newVA()
			locA=A:KL_copyV3()
		end
		out:KL_projectV3(locA,B)
		out:KL_subV3(locA,out)
		return out
	end,
	---@endsection

	---@section KL_rejectV4
	---rejects A from B, output is in direction A
	---@param out table
	---@param A table
	---@param B table
	KL_rejectV4=function(out,A,B)
		local locA=A
		if out==A then
			--safeguard for when A and out are the same vector
			locA=A.KL_newVA()
			locA=A:KL_copyV4()
		end
		out:KL_projectV4(locA,B)
		out:KL_subV4(locA,out)
		return out
	end,
	---@endsection

	---@section KL_rejectVA
	---rejects A from B, output is in direction A
	---@param out table
	---@param A table is dominant over B in regards to the output size
	---@param B table
	KL_rejectVA=function(out,A,B)
		local locA=A
		if out==A then
			--safeguard for when A and out are the same vector
			locA=A.KL_newVA()
			locA:KL_setToVA(A)
		end
		out:KL_projectVA(locA,B)
		out:KL_subVA(locA,out)
		return out
	end,
	---@endsection

	---@section KL_lerpV2
	---linearly interpolates output between A at t=0 to B at t=1
	---@param out table
	---@param A table
	---@param B table
	KL_lerpV2=function(out,A,B,t)
		local sacvec=out.KL_newVA()
		sacvec:KL_scaleV2(B,t)
		out:KL_scaleV2(A,1-t)
		out:KL_addV2(out,sacvec)
		return out
	end,
	---@endsection

	---@section KL_lerpV3
	---linearly interpolates output between A at t=0 to B at t=1
	---@param out table
	---@param A table
	---@param B table
	KL_lerpV3=function(out,A,B,t)
		local sacvec=out.KL_newVA()
		sacvec:KL_scaleV3(B,t)
		out:KL_scaleV3(A,1-t)
		out:KL_addV3(out,sacvec)
		return out
	end,
	---@endsection

	---@section KL_lerpV4
	---linearly interpolates output between A at t=0 to B at t=1
	---@param out table
	---@param A table
	---@param B table
	KL_lerpV4=function(out,A,B,t)
		local sacvec=out.KL_newVA()
		sacvec:KL_scaleV4(B,t)
		out:KL_scaleV4(A,1-t)
		out:KL_addV4(out,sacvec)
		return out
	end,
	---@endsection

	---@section KL_lerpVA
	---linearly interpolates output between A at t=0 to B at t=1
	---@param out table
	---@param A table
	---@param B table
	KL_lerpVA=function(out,A,B,t)
		local sacvec=out.KL_newVA()
		sacvec:KL_scaleVA(B,t)
		out:KL_scaleVA(A,1-t)
		out:KL_addVA(out,sacvec)
		return out
	end,
	---@endsection

	---@section KL_matMultV2
	---@param out table
	---@param A table
	---@param mat table matrix
	KL_matMultV2=function(out,A,mat)
		out:KL_setV2(mat[1][1]*A[1]+mat[1][2]*A[2],
			mat[2][1]*A[1]+mat[2][2]*A[2]
		)
		return out
	end,
	---@endsection

	---@section KL_matMultV3
	---@param out table
	---@param A table
	---@param mat table
	KL_matMultV3=function(out,A,mat)
		out:KL_setV3(mat[1][1]*A[1]+mat[1][2]*A[2]+mat[1][3]*A[3],
			mat[2][1]*A[1]+mat[2][2]*A[2]+mat[2][3]*A[3],
			mat[3][1]*A[1]+mat[3][2]*A[2]+mat[3][3]*A[3]
		)
		return out
	end,
	---@endsection

	---@section KL_matMultV4
	---@param out table
	---@param A table
	---@param mat table
	KL_matMultV4=function(out,A,mat)
		out:KL_setV4(mat[1][1]*A[1]+mat[1][2]*A[2]+mat[1][3]*A[3]+mat[1][4]*A[4],
			mat[2][1]*A[1]+mat[2][2]*A[2]+mat[2][3]*A[3]+mat[2][4]*A[4],
			mat[3][1]*A[1]+mat[3][2]*A[2]+mat[3][3]*A[3]+mat[3][4]*A[4],
			mat[4][1]*A[1]+mat[4][2]*A[2]+mat[4][3]*A[3]+mat[4][4]*A[4]
		)
		return out
	end,
	---@endsection

	---@section KL_matMultVA
	---@param out table
	---@param A table
	---@param mat table
	KL_matMultVA=function(out,A,mat)
		local locA,v=A
		if out==A then locA=A:KL_copyVA() end
		for row_i,row_t in KL_ipairs(mat) do
			v=0
			for column,weight in KL_pairs(row_t) do
				v=v+weight*locA[column]
			end
			out[row_i]=v
		end
		return out:KL_pruneVA(#mat)
	end,
	---@endsection

	---@section KL_activateVA
	---@param A table
	---@param activation number|string currently supported: binarystep,ternarystep,atanh,leakyrelu,softstep,softplus,softmax,hardmax
	---@param out table|nil vector that you wish to modify as output, leave nil for new one
	---@return table object with methods
	KL_activateVA=function(A,activation,out)
		local count,e,tmp1,tmp2,x=#A,math.exp(1),0,0
		out=out or KineticaL.KL_Vectora.KL_newV()
		--can accept strings in which case they're changed to no cap and no spaces
		--if you get an error here then congrats, you're trying to activate with something that doesn't exist
		--x() is just a guard to ensure error doesn't go quiet and unnoticed

		do
			if activation==0 then			--	binary step			0 / 1
				for i=1,count do
					out[i]=		A[i]>0 and 1 or 0
				end
			elseif activation==1 then		--	ternary step		-1 / 0 / 1
				for i=1,count do
					x=A[i]
					out[i]=		x>=0.5 and 1 or x<=-0.5 and -1 or 0
				end
			elseif activation==2 then		--	atanh				-1 to 1
				for i=1,count do
					x=A[i]
					tmp1=e^x
					tmp2=e^-x
					out[i]=		(tmp1-tmp2)/(tmp1+tmp2)
				end
			elseif activation==3 then		--	leaky relu			-inf to inf
				for i=1,count do
					x=A[i]
					out[i]=	x>0 and x or x/100
				end
			elseif activation==4 then		--	soft step			0 to 1
				for i=1,count do
					out[i]=		1/(1+e^-A[i])
				end
			elseif activation==5 then		--	squared linear		-1 to inf
				for i=1,count do
					x=A[i]
					out[i]=		x+x^2/(1+(x^2)^0.5)
				end
			elseif activation==6 then		--	softmax				0 to 1
				for i=1,count do
					tmp1=tmp1+e^A[i]
				end
				for i=1,count do
					out[i]=	e^A[i]/tmp1
				end
			elseif activation==7 then		--	hardmax				0 to 1
				for i=1,count do
					x=A[i]
					tmp1=x>tmp1 and x or tmp1
				end
				for i=1,count do
					out[i]=	e^A[i]/tmp1
				end
			end
		end

		return out
	end,
	---@endsection

	---@section KL_reverse_activateVA
	---@param A table
	---@param activation number|string currently supported: binarystep,ternarystep,atanh,leakyrelu,softstep,softplus,softmax,hardmax
	---@param out table|nil vector that you wish to modify as output, leave nil for new one
	---@return table object with methods
	KL_reverse_activateVA=function(A,activation,out)
		local count,e,tmp1,tmp2,ln,x=#A,math.exp(1),0,0,math.log
		out=out or KineticaL.KL_Vectora.KL_newVA()
		--can accept strings in which case they're changed to no cap and no spaces
		--if you get an error here then congrats, you're trying to activate with something that doesn't exist
		--x() is just a guard to ensure error doesn't go quiet and unnoticed

		do
			if activation==0 then			--	binary step			0 / 1
				for i=1,count do
					out[i]=		A[i]==1 and 1 or -1
				end
			elseif activation==1 then		--	ternary step		-1 / 0 / 1
				for i=1,count do
					x=A[i]
					out[i]=		x>=0.5 and 1 or x<=-0.5 and -1 or 0
					out[i]=		x==1 and 1 or x==0 and 0 or -1
				end
			elseif activation==2 then		--	atanh				-1 to 1
				for i=1,count do
					x=A[i]
					x=x>0.9999999999 and 0.9999999999 or x<-0.9999999999 and -0.9999999999 or x
					out[i]=		math.log((1+x)/(1-x))/2
				end
			elseif activation==3 then		--	leaky relu			-inf to inf
				for i=1,count do
					x=A[i]
					out[i]=	x>0 and x or x*100
				end
			elseif activation==4 then		--	soft step			0 to 1
				for i=1,count do
					x=A[i]
					out[i]=		ln(x/(1-x))
				end
			elseif activation==5 then		--	squared linear		0 to inf
				--todo
			elseif activation==6 then		--	softmax				0 to 1
				--todo
			elseif activation==7 then		--	hardmax				0 to 1
				--todo
			end
		end

		return out
	end,
	---@endsection
}
---@endsection KL_VECTORACLASS