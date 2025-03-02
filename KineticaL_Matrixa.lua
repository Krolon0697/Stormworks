
---@section __LB_SIMULATOR_ONLY_KINETICAL_MATRIXA__
local KineticaL,KL_ipairs,KL_pairs,KL_insert,KL_remove,KL_type=KineticaL,ipairs,pairs,table.insert,table.remove,type
---@endsection

---@section KL_Matrixa 1 KL_MATRIXACLASS
KL_Matrixa={
	---@section KL_newVM
	---@param ... number matrix contents in row-major order
	---@return table object with methods
	KL_newVM=function(columns,rows,...)
		local matrix,entries={},{...}
		for i,v in KL_pairs(KineticaL.Matrixa) do
			matrix[i]=v
		end
		for row=1,rows do
			matrix[row]={}
			for column=1,columns do
				matrix[row][column]=entries[column+(row-1)*rows] or 0
			end
		end
		return matrix
	end,
	---@endsection

	---@section KL_newTM
	---@param ... table each entry being a complete row
	---@return table object with methods
	KL_newTM=function(...)
		local matrix={...}
		for i,v in KL_pairs(KineticaL.Matrixa) do
			matrix[i]=v
		end
		return matrix
	end,
	---@endsection

	---@section KL_copySM
	---@param A table matrix
	---@return table object with methods
	KL_copySM=function(A)
		local rows,unpack={},table.unpack
		for i,row in KL_ipairs(A) do
			rows[i]={unpack(row)}
		end
		return A.KL_newTM(unpack(rows))
	end,
	---@endsection

	---@section KL_copyQM
	---@param A table matrix
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table object with methods
	KL_copyQM=function(A,out)
		out=out or A.KL_newTM()
		out:KL_setToM(A)
		return out
	end,
	---@endsection

	---@section KL_setToM
	---@param A table matrix to be updated
	---@param B table matrix to take data from
	KL_setToM=function(A,B)
		local unpack=table.unpack
		for rowi,row in KL_ipairs(B) do
			A[rowi]={unpack(row)}
		end
		A:KL_ensureRowsM(#B)
	end,
	---@endsection

	---@section KL_verifySquareM
	---true for square matrices
	---@param A table matrix
	---@return boolean
	KL_verifySquareM=function(A)
		return #A==#A[1]
	end,
	---@endsection

	---@section KL_verifyMatchingDimensions
	---true for square matrices
	---@param A table matrix
	---@return boolean
	KL_verifyMatchingDimensions=function(A,B)
		return #A==#B and #A[1]==#B[1]
	end,
	---@endsection

	---@section KL_getValue
	---acts as a tutorial on the internal representation
	---@param A table matrix
	---@param column number
	---@param row number
	---@return number
	KL_getValue=function(A,column,row)
		return A[row][column]
	end,
	---@endsection

	---@section KL_setValue
	---@param A table matrix
	---@param column number
	---@param row number
	---@param v number 
	KL_setValue=function(A,column,row,v)
		A[row][column]=v
	end,
	---@endsection

	---@section KL_ensureRowsM
	--will create up to this many rows and prune any excess. Doesn't fill in the values for columns
	---@param A table
	---@param rows integer
	KL_ensureRowsM=function(A,rows)
		local s1,s2,check=#A+1,rows,true
		if s1>s2 then s1,s2,check=s2+1,s1,false end
		for row=s1,s2 do
			A[row]=check and {} or nil
		end
	end,
	---@endsection

	---@section KL_pruneColumnsToSize
	--will create up to this many rows and prune any excess. Pads with 0s if it has to
	---@param A table
	---@param columns integer
	KL_pruneColumnsToSize=function(A,columns)
		local s,v=#A[1]
		if s>columns then
			for i=s,columns+1,-1 do
				KL_remove(A,i)
			end
		elseif columns>s then
			for row=1,#A do
				v=A[row]
				for column=s+1,columns do
					v[column]=0
				end
			end
		end
	end,
	---@endsection

	---@section KL_addSM
	---@param A table matrix
	---@param B table matrix
	---@param scaleB number makes up for subtracting and allows scaling, defaults to 1
	---@return table|nil object with methods, if dimensions don't match returns nil
	KL_addSM=function (A,B,scaleB)
		if not A:KL_verifyMatchingDimensions(B) then return end
		local columns,out=#A[1],A.KL_newTM()
		scaleB=scaleB or 1
		for row=1,#A do
			out[row]={}
			for column=1,columns do
				out[row][column]=A[row][column]+B[row][column]*scaleB
			end
		end
		return out
	end,
	---@endsection

	---@section KL_addQM
	---@param A table matrix
	---@param B table matrix
	---@param scaleB number makes up for subtracting and allows scaling, defaults to 1
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table|nil object with methods, if dimensions don't match returns nil
	KL_addQM=function (A,B,scaleB,out)
		if not A:KL_verifyMatchingDimensions(B) then return end
		local columns,Arow,Brow=#A[1]
		scaleB=scaleB or 1
		out=out or A.KL_newTM()
		out:KL_ensureRowsM(#A)
		for rowi,outrow in KL_ipairs(out) do
			Arow,Brow=A[rowi],B[rowi]
			for column=1,columns do
				outrow[column]=Arow[column]+Brow[column]*scaleB
			end
		end
		out:KL_pruneColumnsToSize(columns)
		return out
	end,
	---@endsection

	---@section KL_scaleSM
	---@param A table matrix
	---@param scaleBy number
	---@return table object with methods
	KL_scaleSM=function(A,scaleBy)
		local out,columns=A.KL_newTM(),#A[1]
		for row=1,#A do
			out[row]={}
			for column=1,columns do
				out[row][column]=A[row][column]*scaleBy
			end
		end
		return out
	end,
	---@endsection

	---@section KL_scaleQM
	---@param A table matrix
	---@param scaleBy number
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table object with methods
	KL_scaleQM=function(A,scaleBy,out)
		local columns=#A[1]
		out=out or A.KL_newTM()
		out:KL_ensureRowsM(#A)
		for row=1,#A do
			for column=1,columns do
				out[row][column]=A[row][column]*scaleBy
			end
		end
		out:KL_pruneColumnsToSize(columns)
		return out
	end,
	---@endsection

	---@section KL_transposeSM
	---@param A table matrix
	---@return table object with methods
	KL_transposeSM=function(A)
		local columns,out=#A,A.KL_newTM()
		for row=1,#A[1] do
			out[row]={}
			for column=1,columns do
				out[row][column]=A[column][row]
			end
		end
		return out
	end,
	---@endsection

	---@section KL_transposeQM
	---@param A table matrix
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table object with methods
	KL_transposeQM=function(A,out)
		local columns=#A
		out=out or A.KL_newTM()
		out:KL_ensureRowsM(columns)
		for row=1,#A[1] do
			for column=1,columns do
				out[row][column]=A[column][row]
			end
		end
		out:KL_pruneColumnsToSize(#A)
		return out
	end,
	---@endsection

	---@section KL_multiplySM
	---@param A table matrix
	---@param B table matrix
	---@return table|nil object with methods, returns nil if dimensions don't match
	KL_multiplySM=function (A,B)
		local s,out,columns,v=#A[1],A.KL_newTM(),#B[1]
		if s~=#B then return end
		for row=1,#A do
			out[row]={}
			for column=1,columns do
				v=0
				for k=1,s do
					v=v+A[row][k]*B[k][column]
				end
				out[row][column]=v
			end
		end
		return out
	end,
	---@endsection

	---@section KL_multiplyQM
	---@param A table matrix
	---@param B table matrix
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table|nil object with methods, returns nil if dimensions don't match
	KL_multiplyQM=function (A,B,out)
		local s,columns,v=#A[1],#B[1]
		if s~=#B then return end
		out=out or A.KL_newTM()
		out:KL_ensureRowsM(#A)
		for row=1,#A do
			for column=1,columns do
				v=0
				for k=1,s do
					v=v+A[row][k]*B[k][column]
				end
				out[row][column]=v
			end
		end
		out:KL_pruneColumnsToSize(columns)
		return out
	end,
	---@endsection

	---@section KL_minorSM
	---@param A table matrix of which minor is required
	---@param column number column of the minor
	---@param row number row of the minor
	---@return table matrix
	KL_minorSM=function(A,row,column)
		local out=A:KL_copySM()
		KL_remove(out,row)
		for row=1,#out do
			KL_remove(out[row],column)
		end
		return out
	end,
	---@endsection

	---@section KL_minorQM
	---@param A table matrix of which minor is required
	---@param column number column of the minor
	---@param row number row of the minor
	---@param out table matrix|nil matrix that you wish to modify as output, leave nil for new one
	---@return table matrix
	KL_minorQM=function(A,row,column,out)
		out=out or A.KL_newTM()
		out:KL_setToM(A)
		KL_remove(out,row)
		for row=1,#out do
			KL_remove(out[row],column)
		end
		out:KL_pruneColumnsToSize(#A[1]-1)
		return out
	end,
	---@endsection

	---@section KL_detM
	---@param A table matrix
	---@return number|nil determinant may return nil if matrix isn't square (or something breaks idk)
	KL_detM=function(A)
		local t,mult=A:KL_upperTriangleM()
		if t then
			for i=1,#t do
				mult=mult*t[i][i]
			end
			return mult
		end
	end,
	---@endsection

	---@section KL_upperTriangleM
	---@param A table matrixv
	---@return table|nil upper will return nil if A isn't square
	---@return number|nil sign in case of switching rows, will return a 1 or -1 to multiply the determinant
	KL_upperTriangleM=function(A,out)
		if not A:KL_verifySquareM() then return end
		local size,sign,out,mult=#A,1,A:KL_copySM()
		for row=2,size do
			for column=1,row-1 do
				if out[column][column]==0 then
					for i=column+1,size do
						if out[i][column]~=0 then
							sign=-sign
							out[i],out[column]=out[column],out[i]
							goto continue
						end
					end
					goto done
				end
				::continue::
				mult=out[row][column]/out[column][column]
				for i=column,size do
					out[row][i]=out[row][i]-out[column][i]*mult
				end
			end
		end
		::done::
		return out,sign
	end,
	---@endsection

	---@section KL_cofactorM
	---@param A table matrixv
	---@return table|nil matrix will return nil if matrix isn't square
	KL_cofactorM=function(A)
		if not A:KL_verifySquareM() then return end
		local columns,out=#A[1],A.KL_newTM()
		for row=1,#A do
			out[row]={}
			for column=1,columns do
				out[row][column]=(-1)^(row+column)*A:KL_minorM(row,column):KL_detM()
			end
		end
		return out
	end,
	---@endsection

	---@section KL_inverseM
	---very bad, but works
	---@param A table matrix
	---@return table|nil matrix will return nil if matrix isn't square or it's determinant is 0
	KL_inverseM=function(A)
		local det,out=A:KL_detM()
		if det==0 or not det or not A:KL_verifySquareM() then return end
		out=A:KL_cofactorM()
		out=out:KL_transposeM()
		return out:KL_scaleM(1/det)
	end,
	---@endsection

	---@section KL_identityM
	---@param size integer return an size x size identity matrix
	---@param value number|nil the value to fill on the diagonal
	---@return table object with methods
	KL_identityM=function(size,value)
		local out=KineticaL.KL_Matrixa.KL_newTM()
		value=value or 1
		for row=1,size do
			out[row]={}
			for column=1,size do
				out[row][column]=0
			end
			out[row][row]=value
		end
		return out
	end,
	---@endsection

	---@section KL_qrSquareDecompositionM
	---@param A table square matrix
	---@return table Q matrix
	---@return table R matrix
	KL_qrSquareDecompositionM=function(A)
		local size,A_cols,newM,vecLib,unpack=#A,A:KL_transposeM(),KineticaL.KL_Matrixa.KL_newVM,KineticaL.KL_Vectora,table.unpack
		local R,Q_columns,dot,mag,v,Q_col,r,rii,val=newM(size,size),newM(0,size),vecLib.KL_dotVA,vecLib.KL_magnitudeVA
		for i=1,size do
			v={unpack(A_cols[i])}
			for j=1,i-1 do
				Q_col=Q_columns[j]
				r=dot(Q_col,A_cols[i])
				R[j][i]=r
				for k=1,size do
					v[k]=v[k]-r*Q_col[k]
				end
			end
			rii=mag(v)
			R[i][i]=rii
			for j=1,size do
				val=v[j]/rii
				v[j]=val==val and val or 0
			end
			Q_columns[i]=v
		end
	
		return Q_columns:KL_transposeM(),R
	end,
	---@endsection

	---@section KL_qrEigenvaluesM
	KL_qrEigenvaluesM=function(A,max_iter,normalize)
		max_iter=max_iter or 100

		local iter,size,eigenvalues,unpack,Q_total,newVec,Q,R,off_diag,v,moooo=0,#A,{},table.unpack,KineticaL.KL_Matrixa.KL_identityM(#A),KineticaL.KL_Vectora.KL_newVA
		repeat
			iter=iter+1
			moooo=iter<=2 and 0 or A[size][size]

			for i=1,size do
				A[i][i]=A[i][i]-moooo
			end
			Q,R=A:KL_qrSquareDecompositionM()
			Q_total=Q_total:KL_multiplyM(Q)--matrix_multiply(Q_total,Q)
			A=R:KL_multiplyM(Q)--matrix_multiply(R,Q)
			for i=1,size do
				A[i][i]=A[i][i]+moooo
			end

		-- Check convergence: sum of off-diagonals
			off_diag=0
			for i=1,size do
				for j=1,size do
					off_diag=off_diag+(i~=j and (A[i][j]^2)^0.5 or 0)
				end
			end
		until off_diag<0.001 or iter>=max_iter

		for i=1,size do
			eigenvalues[i]=A[i][i]
		end
		Q_total=Q_total:KL_transposeM()
		for i,vec in KL_ipairs(Q_total) do
			v=newVec(unpack(vec))
			Q_total[i]=normalize and v:KL_unitVA(v) or v
			for i=1,size do
				v[i]=v[i]==v[i] and v[i] or 0
			end
		end
		return Q_total,newVec(unpack(eigenvalues))
	end,
	---@endsection

	---@section KL_svdM
	KL_svdM=function(A,max_iter)
		max_iter=max_iter or 100
		local newMat,newVec=KineticaL.KL_Matrixa.KL_newVM,KineticaL.KL_Vectora.KL_newVA
		local sacVec,At,AtA,AAt,eivals,AtAeivecs,AAteivecs,E,V,U,completeBasisSize,biggerMatEivecs=newVec()

		local function completeBasis()
			local repeats,rng,candidate=0,KineticaL.KL_random
			repeat
				repeats=repeats+1
				candidate=newVec()
				for i=1,completeBasisSize do
					candidate[i]=(rng()-0.5)*20000
				end
				for i,vec in KL_ipairs(biggerMatEivecs) do
					candidate:KL_projectVA(vec,sacVec)
					candidate:KL_subVA(sacVec,candidate)
				end
				if candidate:KL_magnitudeVA()>1e-9 then
					repeats=0
					KL_insert(biggerMatEivecs,candidate:KL_unitVA(candidate))
				end
			until #biggerMatEivecs==completeBasisSize or repeats>max_iter
			return #biggerMatEivecs==completeBasisSize
		end

		At=A:KL_transposeM()
		AtA=At:KL_multiplyM(A)
		AAt=A:KL_multiplyM(At)
		--for a 2x3 or 3x2 matrix we only need 2 eigenvalues so discard the larger batch since it's only an added 0
		if #AtA>#AAt then
			AtAeivecs=AtA:KL_qrEigenvaluesM(max_iter,true)
			AAteivecs,eivals=AAt:KL_qrEigenvaluesM(max_iter,true)
			biggerMatEivecs=AtAeivecs
		else
			AtAeivecs,eivals=AtA:KL_qrEigenvaluesM(max_iter,true)
			AAteivecs=AAt:KL_qrEigenvaluesM(max_iter,true)
			biggerMatEivecs=AAteivecs
		end

		completeBasisSize=#biggerMatEivecs
		for i=#biggerMatEivecs,1,-1 do
			--check the zero eigenvectors to yeet them, if mag is 1 then is good but numerical stability can make it 0.99999
			if biggerMatEivecs[i]:KL_magnitudeVA()<0.5 then
				KL_remove(biggerMatEivecs,i)
			end
		end

		--sort eigenvectors
		for i,matrix in KL_ipairs({AtAeivecs,AAteivecs}) do
			for j,eivec in KL_ipairs(matrix) do
				eivec:KL_matMultVA(matrix==AtAeivecs and AtA or AAt,sacVec)
				eivec.eival=sacVec:KL_magnitudeVA()
			end
			table.sort(matrix,function (a, b)
				return a.eival>b.eival
			end)
		end

		if #biggerMatEivecs<completeBasisSize and not completeBasis() then
			return print('failed to do SVD, not enough iterations')
		end

		E=newMat(#A[1],#A)
		for i,eival in KL_ipairs(eivals) do
			E[i][i]=eival^0.5
		end
		U=AAteivecs:KL_transposeM()
		V=AtAeivecs

		return U,E,V
	end,
	---@endsection

	---@section KL_printMat
	---@param A table matrix
	---@param prefix string|nil a prefix to the output string
	---@param suffix string|nil a suffix appended at the output string
	KL_printMat=function(A,prefix,suffix)
		local txt,last_val,last_substring,substring=prefix and prefix..'\n' or ''
		for i,row in KL_ipairs(A) do
			last_substring=''
			last_val=1
			for j,val in KL_ipairs(row) do
				substring=string.format('%.3f',val)
				txt=txt..string.rep(' ',(val<0 and 10 or 11)-#last_substring+(last_val<0 and 1 or 0))..substring
				last_substring=substring
				last_val=val
			end
			txt=txt..(i~=#A and '\n' or '')
		end
		print(txt..(suffix and '\n'..suffix or ''))
	end
	---@endsection
}
---@endsection KL_MATRIXACLASS