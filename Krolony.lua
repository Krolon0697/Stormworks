
---@diagnostic disable:unbalanced-assignments

---@section gN
	gN=input.getNumber
---@endsection
---@section gB
	gB=input.getBool
---@endsection
---@section sN
	sN=output.setNumber
---@endsection
---@section sB
	sB=output.setBool
---@endsection

---@section max
	max=math.max
---@endsection
---@section min
	min=math.min
---@endsection
---@section abs
	abs=math.abs
---@endsection
---@section sqrt
	sqrt=math.sqrt
---@endsection
---@section log
	log=math.log
---@endsection
---@section flr
	flr=math.floor
---@endsection
---@section ceil
	ceil=math.ceil
---@endsection
---@section pi
	pi=math.pi
---@endsection
---@section cos
	cos=math.cos
---@endsection
---@section sin
	sin=math.sin
---@endsection
---@section tan
	tan=math.tan
---@endsection
---@section acos
	acos=math.acos
---@endsection
---@section asin
	asin=math.asin
---@endsection
---@section atan
	atan=math.atan
---@endsection

---@section ti
	ti=table.insert
---@endsection
---@section tr
	tr=table.remove
---@endsection
---@section ts
	ts=table.sort
---@endsection
---@section tu
	tu=table.unpack
---@endsection

---@section dT
	dT=screen.drawText
---@endsection
---@section dL
	dL=screen.drawLine
---@endsection
---@section dR
	dR=screen.drawRect
---@endsection
---@section dRF
	dRF=screen.drawRectF
---@endsection
---@section dC
	dC=screen.drawCircle
---@endsection
---@section dCF
	dCF=screen.drawCircleF
---@endsection
---@section dTr
	dTr=screen.drawTriangle
---@endsection
---@section dTrF
	dTrF=screen.drawTriangleF
---@endsection
---@section sC
	sC=screen.setColor
---@endsection

---@section profilerTime
function profilerTime(name)
	return {
	t=os.clock(),
	name=name,
	start=function(self)
		self.t=os.clock()
	end,
	stop=function (self)
		print((self.name or '')..string.format('%.0f',1000*(os.clock()-self.t))..'ms')
		self.t=os.clock()
	end
	}
end
---@endsection

---@section profileFunction
function profileFunction(func,...)
	local time,outputs=os.clock()
	outputs={func(tu({...}))}
	print(string.format('%.0f',1000*(os.clock()-time))..'ms')
	return tu(outputs)
end
---@endsection

---@section Vector3 1 VECTOR3DCLASS
Vector3=--3D
{
---@section New
	New=function(x,y,z)return {x,y,z,
		Add=function (self,B)
			for i=1,3 do
				self[i]=self[i]+B[i]
			end
		end,
		Sub=function (self,B)
			for i=1,3 do
				self[i]=self[i]-B[i]
			end
		end,
		Dot=function(self,B)
			return self[1]*B[1]+self[2]*B[2]+self[3]*B[3] 
		end,
		Scale=function(self,B)
			for i=1,3 do
				self[i]=self[i]*B
			end
		end,
		Magnitude=function(self,B)
			for i=1,3 do
				self[i]=self[i]*B
			end
		end,
	} end,
---@endsection

---@section Add
	Add=function(A,B)return {A[1]+B[1],A[2]+B[2],A[3]+B[3]} end,
---@endsection

---@section Sub
	Sub=function(A,B)return {A[1]-B[1],A[2]-B[2],A[3]-B[3]} end,
---@endsection
---@section Dot
	Dot=function(A,B)return A[1]*B[1]+A[2]*B[2]+A[3]*B[3] end,
---@endsection
---@section Scale

---A is number to scale by, B is table
	Scale=function(A,B)return {A*B[1],A*B[2],A*B[3]} end,
---@endsection
---@section Magnitude

---length of vector
	Magnitude=function(A)return (A[1]*A[1]+A[2]*A[2]+A[3]*A[3])^0.5 end,
---@endsection
---@section Cross
	Cross=function(A,B)return {A[2]*B[3]-A[3]*B[2],A[3]*B[1]-A[1]*B[3],A[1]*B[2]-A[2]*B[1]}end,
---@endsection
---@section Angle

---get shortest path angle between 2 vectors
	Angle=function(A,B)return acos(clamp(-1,1,Vector3.Dot(A,B)/(Vector3.Magnitude(A)*Vector3.Magnitude(B))))end,
---@endsection
---@section Unit
	Unit=function(A)return Vector3.Scale(1/Vector3.Magnitude(A),A)end,
---@endsection
---@section ScalarProject

---ngl I don't even fucking know what this is but it scalarly projects A onto B whatever that means
	ScalarProject=function(A,B)return Vector3.Dot(A,Vector3.Unit(B))end,
---@endsection
---@section Project

---project A onto B
	Project=function(A,B)return Vector3.Scale(Vector3.Dot(A,B)/Vector3.Dot(B,B),B)end,
---@endsection
---@section Reject

	Reject=function(A,B)return Vector3.Sub(A,Vector3.Project(A,B))end
---@endsection
}
---@endsection VECTOR3DCLASS

---@section VectorAny 1 VECTORANYCLASS
VectorAny=--3D
{
---@section Add
	Add=function(A,B)local c={} for i=1,max(#A,#B) do c[i]=(A[i] or 0)+(B[i] or 0) end return c end,
---@endsection

---@section Sub
	Sub=function(A,B)local c={} for i=1,max(#A,#B) do c[i]=(A[i] or 0)-(B[i] or 0) end return c end,
---@endsection
---@section Dot
	Dot=function(A,B)local c=0 for i=1,max(#A,#B) do c=c+(A[i] or 0)*(B[i] or 0) end return c end,
---@endsection
---@section Scale

---A is number to scale by, B is table
	Scale=function(A,B)local c={} for i=1,#B do c[i]=A*B[i] end return c end,
---@endsection
---@section Magnitude

---length of vector
	Magnitude=function(A)local c=0 for i=1,#A do c=c+A[i]*A[i] end return c^0.5 end,
---@endsection
---@section Angle

---get shortest path angle between 2 vectors
	Angle=function(A,B)return acos(clamp(-1,1,VectorAny.Dot(A,B)/(VectorAny.Magnitude(A)*VectorAny.Magnitude(B))))end,
---@endsection
---@section Unit
	Unit=function(A)return VectorAny.Scale(1/VectorAny.Magnitude(A),A)end,
---@endsection
---@section ScalarProject

---ngl I don't even fucking know what this is but it scalarly projects A onto B whatever that means
	ScalarProject=function(A,B)return VectorAny.Dot(A,VectorAny.Unit(B))end,
---@endsection
---@section Project

---project A onto B
	Project=function(A,B)return VectorAny.Scale(VectorAny.Dot(A,B)/VectorAny.Dot(B,B),B)end,
---@endsection
---@section Reject

	Reject=function(A,B)return VectorAny.Sub(A,VectorAny.Project(A,B))end
---@endsection
}
---@endsection VECTORANYCLASS

---@section Matrix 1 MATRIXCLASS
Matrix=
{
	---@section Add
	Add=function (A,B)
		local c={}
		for i=1,#A do
			c[i]={}
			for j=1,#A[1] do
				c[i][j]=(A[i][j] or 0)+(B[i][j] or 0)
			end
		end
		return c
	end,
	---@endsection
	---@section Scale
	Scale=function (A,B)
		local c,a,b={}
		for i=1,#B do
			c[i]={}
			for j=1,#B[1] do
				c[i][j]=A*B[i][j]
			end
		end
		return c
	end,
	---@endsection
	---@section Transpose
	Transpose=function (A)
		local c={}
		for i=1,#A do
			c[i]={}
			for j=1,#A[1] do
				c[i][j]=A[j][i]
			end
		end
		return c
	end,
	---@endsection
	---@section Mult
	Mult=function (A,B)
		local c,v={}
		for i=1,#A do
			c[i]={}
			for j=1,#B[1] do
				v=0
				for k=1,#A[1] do
					v=v+A[i][k]*B[k][j]
				end
				c[i][j]=v
			end
		end
		return c
	end,
	---@endsection
	---@section upperTriangle
	upperTriangle=function(A)
		local c,size,mult=A,#A
		for i=2,size do
			for j=i,size do
				mult=c[j][i-1]/c[i-1][i-1]
				for k=1,size do
					c[j][k]=c[j][k]-mult*c[i-1][k]
				end
			end
		end
		return c
	end,
	---@endsection
	---@section Det
	Det=function (A)
		local c,v=Matrix.upperTriangle(A),1
		for i=1,#c do
			v=v*c[i][i]
		end
		return v
	end,
	---@endsection
	---@section oneDTableToColumnVector
	oneDTableToColumnVector=function (A)
		local c={}
		for i=1,#A do
			c[i]={A[i]}
		end
		return c
	end,
	---@endsection
	---@section oneDTableToRowVector
	oneDTableToRowVector=function (A)
		return {A}
	end,
	---@endsection
	---@section Identity
	Identity=function (size)
		local c={}
		for i=1,size do
			c[i]={}
			for j=1,size do
				c[i][j]=i==j and 1 or 0
			end
		end
		return c
	end
	---@endsection

}
---@endsection MATRIXCLASS

---@section fourier 1 FOURIERCLASS
fourier={
	---@section fftSize
    fftSize=function(n)
        return 2^ceil(log(n,2))
    end,
	---@endsection

	---@section rescaleDown
	---@return void
    rescaleDown=function(input)
        --used to rescale outputs of fourier transform down by N, as that's what fourier does
        local scale=1/(#input+1)
        for i=0,#input do
            input[i].real=input[i].real*scale
            input[i].imag=input[i].imag*scale
        end
    end,
	---@endsection

	---@section getAmplitudes
    getAmplitudes=function(fhat)
        --formula for frequency is k/(N*dT), can be done in a loop after using this function to to get amplitudes of frequqncies
        local amp,peak,math={},0
        for i=0,#fhat do
			math=(fhat[i].real^2+fhat[i].imag^2)^0.5
			peak=max(peak,math)
            amp[i]=math
        end
        return amp,peak
    end,
	---@endsection

	---@section getComplexOmega
    getComplexOmega=function(k,N)
        --global helper function used in every fourier transform
        return {real=cos(2*pi*k/N),imag=sin(2*pi*k/N)}
    end,
	---@endsection

	---@section dft
    dft=function(input,inverse)
        --quite small, but very slow algorithm, may be useful in small N sizes when exact frequencies are required without 0-padding
        --can take either 1-indexed tables {1,2,3,4} or 0-indexed complex values {{real=1,imag=0},{real=2,imag=0},{real=3,imag=0},{real=4,imag=0}}
        --it has no protection from N-size other than a power of 2 when being fed with complex values, as that seemed excessive
        --will only output 0-indexed complex values, even if they represent just the real values
        local Mult=function (A,B)
            --a little simplified typical matrix multiplication, it only works on matrix*vector so no need to implement in full
            local c,v,realA,imagA,realB,imagB={}
            for i=0,#A do
                c[i]={real=0,imag=0}
                for k=0,#A[i] do
                    realA=A[i][k].real
                    imagA=A[i][k].imag
                    realB=B[k].real
                    imagB=B[k].imag
                    c[i].real=c[i].real+realA*realB-imagA*imagB
                    c[i].imag=c[i].imag+realA*imagB+imagA*realB
                end
            end
            return c
        end
        local genDFTMatrix=function(N,inverse)
            local dft,k={}
            for i=0,N-1 do
                dft[i]={}
                for j=0,N-1 do
                    k=(i)*(j)*(inverse and -1 or 1)
                    dft[i][j]=fourier.getComplexOmega(k,N)
                end
            end
            return dft
        end

        if UniqueNameDFTMemoryKrolon==nil then UniqueNameDFTMemoryKrolon={} end
        local N,vector,inverse,mem=#input+(input[0]~=nil and 1 or 0),{},inverse or false,UniqueNameDFTMemoryKrolon
        --make sure inputs are safe
        if math.type(input[1]) then
            for i=1,N do
                vector[i-1]={real=input[i],imag=0}
            end
        else
            vector=input
        end

        --keep DFT matrices in memory
        if mem[N]==nil then
            mem[N]={}
            mem[N][true]=genDFTMatrix(N,true)
            mem[N][false]=genDFTMatrix(N)
        end

        return Mult(mem[N][inverse],vector)
    end,
	---@endsection

	---@section fftFast
	fftFast=function(input,inverse,initializeToN)
		--1014 chars, 1678/290 ms initialization/later runs at N=2^15 on my PC
		--matrix FFT implementation optimized as all fuck. I legit no longer have a clue of what's going on. I'm only optimizing further
		--optimized to not produce any garbage, thus avoiding garbage collector lag hugely increasing performance
		--can take either 1-indexed tables {1,2,3,4} or 0-indexed complex values {{real=1,imag=0},{real=2,imag=0},{real=3,imag=0},{real=4,imag=0}}
		--will 0-pad to nearest largest power of 2 when fed with "normal" table for input
		--it has no protection from N-size other than a power of 2 when being fed with complex values, as that seemed excessive
		--will only output 0-indexed complex values, even if they represent just the real values
		local genPermutationOrder=function(N)
			--generates a table of re-ordered 1-indexes, bit reversal
			local bits,V,val=math.log(N,2),{}
			for i=0,N-1 do
				val=1
				for j=1,bits do
					val=val+(i&2^(j-1)==2^(j-1) and 2^(bits-j) or 0)
				end
				V[i]=val
			end
			return V
		end
		local genWeird=function(N,inverse)
			--also close to black magic, generates {I,D,I,-D} simplified matrix
			--edit: not even I D I -D anymore... the optimizations are too far
			local weird,n={},N/2
			for i=0,n-1 do
				weird[i]=fourier.getComplexOmega((i)*(inverse and -1 or 1),N)
				weird[i+n]=fourier.getComplexOmega((n+i)*(inverse and -1 or 1),N)
			end
			return weird
		end

		--initialize memory, locals and functions
		if UniqueNameFFTFMemoryKrolon==nil then UniqueNameFFTFMemoryKrolon={} end
		local N,inverse,mem,vector,V,A,B,C,half,index,A2,B1,B2,rA2,iA2,rB1,rB2,iB1,iB2,r,im=fourier.fftSize(initializeToN or #input),inverse or false,UniqueNameFFTFMemoryKrolon

		--precompute all necessary constants if they're not existing
		V=N
		while mem[V]==nil and V>=1 do
			mem[V]={order=genPermutationOrder(V),matrix={},vector={}}
			mem[V].matrix[true]=genWeird(V,true)
			mem[V].matrix[false]=genWeird(V)
			logn=ceil(log(N,2))
			--t=os.clock()
			for i=0,V-1 do
				mem[V].vector[i]={}
				for j=0,2^(logn-ceil(log((i+1),2)))-1 do
					mem[V].vector[i][j]={real=0,imag=0}
				end
			end
			--print(V,string.format('%.0f',1000*(os.clock()-t)))
			V=V/2
		end
		if initializeToN then return end
		vector=mem[N].vector

		--make sure inputs are correct and reorder them in bit-reversal pattern
		V=mem[N].order
		if math.type(input[1]) then
			for i=0,N-1 do
				vector[i][0].real=input[V[i]] or 0
				vector[i][0].imag=0
			end
		else
			for i=0,N-1 do
				vector[i][0].real=input[V[i]-1].real
				vector[i][0].imag=input[V[i]-1].imag
			end
		end

		--main work FFT loop
		V=1
		while V<N do
			V=V*2
			for i=0,N/V-1 do
				--A,B,C=mem[V].matrix[inverse],vector[2*i],vector[2*i+1]
				A,B,C=mem[V].matrix[inverse],vector[2*i],vector[2*i+1]
				half=(#A+1)/2
				for j=#A,0,-1 do
					index=j%half
					A2=A[j]
					B1=B[index]
					B2=C[index]
					rA2=A2.real
					iA2=A2.imag
					rB1=B1.real
					iB1=B1.imag
					rB2=B2.real
					iB2=B2.imag
					r=rB1+rB2*rA2-iB2*iA2
					im=iB1+iB2*rA2+rB2*iA2
					vector[i][j].real=r
					vector[i][j].imag=im
				end
			end
		end
		vector={}
		for i=0,#mem[N].vector[0] do
			vector[i]={real=mem[N].vector[0][i].real,imag=mem[N].vector[0][i].imag}
		end
		return vector
	end,
	---@endsection

	fftTest=function(input,inverse,initializeToN)
		--matrix FFT implementation optimized as all fuck. I legit no longer have a clue of what's going on. I'm only optimizing further
		--optimized to not produce any garbage, thus avoiding garbage collector lag hugely increasing performance
		--can take either 1-indexed tables {1,2,3,4} or 0-indexed complex values {{real=1,imag=0},{real=2,imag=0},{real=3,imag=0},{real=4,imag=0}}
		--will 0-pad to nearest largest power of 2 when fed with "normal" table for input
		--it has no protection from N-size other than a power of 2 when being fed with complex values, as that seemed excessive
		--will only output 0-indexed complex values, even if they represent just the real values

		--localize shit for user safety
		if UniqueNameFFTFMemoryKrolon==nil then UniqueNameFFTFMemoryKrolon={vector={},orders={}} end
		local N,inverse,mem,vector,V,A,B,C,half,index,A2,B1,B2,rA2,iA2,rB1,rB2,iB1,iB2=fourier.fftSize(initializeToN or #input),inverse or false,UniqueNameFFTFMemoryKrolon

		--precompute all necessary shit into memory
		V=N
		while mem[V]==nil and V>=1 do
			--mem[V]={order=genPermutationOrder(V),matrix={}}
			mem[V]={matrix={}}
			--generate Vth roots of unity for forward or inverse
			for i=-1,1,2 do
				mem[V].matrix[i<0]={}
				for j=0,V-1 do
					mem[V].matrix[i<0][j]=fourier.getComplexOmega(j*i,V)
				end
			end
			V=V/2
		end

		--preoccupy memory for computations, the holy grail of garbage collector avoidance
		--plus reorder first because it's better optimized that way, sorry!
		--not like you care much, it's already convoluted as fuck
		--my next project will be convolutions and wavelets heh ba doom tss
		vector=mem.vector
		if vector[N-1]==nil then
			--generate a table of re-ordered 1-indexes in bit reversal pattern
			--A is reused variable, amount of bits, and log base 2 of N for next step
			A=log(N,2)
			mem.orders[N]={}
			for i=0,N-1 do
				val=1
				for j=1,A do
					val=val+(i&2^(j-1)==2^(j-1) and 2^(A-j) or 0)
				end
				mem.orders[N][i]=val
			end

			--that's the holy grail here
			for i=0,N-1 do
				vector[i]={}
				V=A-ceil(log((i+1),2))
				for j=0,2^V-1 do
					vector[i][j]={real=0,imag=0}
				end
			end
		end
		if initializeToN then return end

		--make sure inputs are correct and reorder them in bit-reversal pattern
		V=mem.orders[N]
		if math.type(input[1]) then
			for i=0,N-1 do
				vector[i][0].real=input[V[i]] or 0
				vector[i][0].imag=0
			end
		else
			for i=0,N-1 do
				vector[i][0].real=input[V[i]-1].real
				vector[i][0].imag=input[V[i]-1].imag
			end
		end

		--main work FFT loop
		V=1
		while V<N do
			V=V*2
			for i=0,N/V-1 do
				--A,B,C=mem[V].matrix[inverse],vector[2*i],vector[2*i+1]
				B,C=vector[2*i],vector[2*i+1]
				A=mem[V].matrix[inverse]
				half=(#A+1)/2
				for j=#A,0,-1 do
					index=j%half
					A2=A[j]
					B1=B[index]
					B2=C[index]
					rA2=A2.real
					iA2=A2.imag
					rB1=B1.real
					iB1=B1.imag
					rB2=B2.real
					iB2=B2.imag
					vector[i][j].real=rB1+rB2*rA2-iB2*iA2
					vector[i][j].imag=iB1+iB2*rA2+rB2*iA2
				end
			end
		end
		vector={}
		for i=0,N-1 do
			vector[i]={real=mem.vector[0][i].real,imag=mem.vector[0][i].imag}
		end
		return vector
	end,
	---@section fftCompact
    fftCompact=function(input,inverse)
        --791 chars, 1266ms/800-1150 av:920ms initialization/later runs at N=2^15 on my PC
        --fftFast sacrificing performance for a little less char count, takes 50% longer to perform
        --can take either 1-indexed tables {1,2,3,4} or 0-indexed complex values {{real=1,imag=0},{real=2,imag=0},{real=3,imag=0},{real=4,imag=0}}
        --it has no protection from N-size other than a power of 2 when being fed with complex values, as that seemed excessive
        --will only output 0-indexed complex values, even if they represent just the real values
        local Mult=function (A,B,C)
            --it's black magic at this point
            local c,half,a,b={},#B+1
            for i=0,#A do
                c[i]={real=0,imag=0}
                for j=0,1 do
                    a=A[i][j+1]
					b=(j==0 and B or C)[i%half]
                    c[i].real=c[i].real+b.real*a.real-b.imag*a.imag
                    c[i].imag=c[i].imag+b.imag*a.real+b.real*a.imag
                end
            end
            return c
        end
        local permute=function(pos,N)
            --reverse bits of pos
            local bits,V=math.log(N,2),1
            for j=1,bits do
                V=V+(pos&2^(j-1)==2^(j-1) and 2^(bits-j) or 0)
            end
            return V
        end
        local genWeird=function(N,inverse)
            --also close to black magic, generates {I,D,I,-D} simplified matrix
            local weird,n={},N/2
            for i=0,n-1 do
                for j=0,1 do
                    weird[i+n*j]={{real=1,imag=0},fourier.getComplexOmega((i+n*j)*(inverse and -1 or 1),N)}
                end
            end
            return weird
        end

        --initialize memory and locals
        if UniqueNameFFTCMemoryKrolon==nil then UniqueNameFFTCMemoryKrolon={} end
        local N,vector,inverse,mem,V=2^ceil(log(#input,2)),{},inverse or false,UniqueNameFFTCMemoryKrolon

        --precompute all necessary "matrices" if they're not existing
        V=N
        while mem[V]==nil and V>=1 do
            mem[V]={matrix={}}
            mem[V].matrix[true]=genWeird(V,true)
            mem[V].matrix[false]=genWeird(V)
            V=V/2
        end

        for i=0,N-1 do
            V=permute(i,N)
            vector[i]={}
            vector[i][0]=math.type(input[1]) and {real=input[V] or 0,imag=0} or input[V-1]
        end

        --main work FFT loop
        V=1
        while V<N do
            V=V*2
            for i=0,N/V-1 do
                vector[i]=Mult(mem[V].matrix[inverse],vector[2*i],vector[2*i+1])
            end
        end
        return vector[0]
    end
	---@endsection
}
---@ensection FOURIERCLASS

---@section buttonsLibrary 1 BUTTONCLASS
buttonsLibrary=
{
	---@section simple 1 SIMPLECLASS
	simple={
		---@section createButton

		---creates a button that you can later access by buttons.['name'].state for example
		createButton=function(name,buttons,x,y,w,h,onRGBA,offRGBA,mode,drawTxt)
			buttons[name]={
				x=x,
				y=y,
				w=w==0 and #name*5+2 or w,
				h=h==0 and 8 or h,
				onRGBA=onRGBA,
				offRGBA=offRGBA,
				mode=mode, --0 for pulse, 1 for push, 2 for toggle
				active=true, --to enable or disable drawing (and touch detection)
				txt=name,
				drawTxt=drawTxt,
				state=false,
				timer=0
			}
		end,
		---@endsection
		--@section manageButtons
	
		---is for rectangles and text
		---manages the touch and button states
		---@param x touch
		---@param y touch
		---@param press boolean
		---@param buttons table
		manageButtons=function(x,y,press,buttons)
			for i,button in pairs(buttons) do
				local hold=x>=button.x and x<=button.x+button.w and y>=button.y and y<=button.y+button.h and press and button.active
				button.timer=hold and button.timer+1 or 0
				button.state=button.mode=='pulse' and button.timer=='hold' or button.mode==1 and button.timer>0 or button.mode=='toggle' and button.state
				if button.mode=='toggle' and button.timer==1 then button.state=not button.state end
			end
		end,
		---@section drawButtons
	
		---is for rectangles and text
		---draws the buttons, all, according to their data
		---@param buttons table
		drawButtons=function(buttons)
			for i,button in pairs(buttons) do
				if button.active then
					sC(tu(button.state and button.onRGBA or button.offRGBA))
					dR(button.x,button.y,button.w,button.h)
					if button.drawTxt then dT(button.x+2,button.y+2,button.txt) end
				end
			end
		end
		---@endsection

	},
	---@endsection SIMPLECLASS
	---@section complex 1 COMPLEXCLASS
	complex={
		---@section manageButtons
	
		---is for complex shapes, no text
		---manages the touch and button states
		---works with both outlines and filled buttons
		---is expensive in characters and probably CPU
		---@param x touch
		---@param y touch
		---@param press boolean
		---@param complexButtons table
		manageButtons=function(x,y,press,complexButtons)
			for i,button in pairs(complexButtons) do
				local temporary=false
				if press and button.active then
					if button.fill and #button.triangles>0 then
						for j,triangle in ipairs(button.triangles) do
							temporary=temporary or inPolygon(x,y,triangle)
						end
					elseif not button.fill and #button.vertices>0 then
						temporary=inPolygon(x,y,button.vertices)
					end
				end
				button.timer=temporary and button.timer+1 or 0
				button.state=button.mode==0 and button.timer==button.delay+1 or button.mode==1 and button.timer>button.delay or button.mode==2 and button.state
				if button.mode==2 and button.timer==button.delay+1 then button.state=not button.state end
			end
		end,
		---@endsection
		---@section manageButtons_onlyFill
	
		---is for complex shapes, no text
		---manages touch and button states
		---only works when you feed it no empty buttons, it has no failcheck
		---is purely for character optimization
		---@param x touch
		---@param y touch
		---@param press boolean
		---@param complexButtons table
		manageButtons_onlyFill=function(x,y,press,complexButtons)
			for i,button in pairs(complexButtons) do
				local temporary=false
				if press and button.active then
					for j,triangle in ipairs(button.triangles) do
						temporary=temporary or inPolygon(x,y,triangle)
					end
				end
				button.timer=temporary and button.timer+1 or 0
				button.state=button.mode==0 and button.timer==button.delay+1 or button.mode==1 and button.timer>button.delay or button.mode==2 and button.state
				if button.mode==2 and button.timer==button.delay+1 then button.state=not button.state end
			end
		end,
		---@endsection
		---@section manageButtons_onlyOutline
	
		---is for complex shapes, no text
		---manages touch and button states
		---only works when you feed it no fill buttons, it has no failcheck
		---is purely for character optimization
		---@param x touch
		---@param y touch
		---@param press boolean
		---@param complexButtons table
		manageButtons_onlyOutline=function(x,y,press,complexButtons)
			for i,button in pairs(complexButtons) do
				local temporary=press and button.active and inPolygon(x,y,button.vertices)
				button.timer=temporary and button.timer+1 or 0
				button.state=button.mode==0 and button.timer==button.delay+1 or button.mode==1 and button.timer>button.delay or button.mode==2 and button.state
				if button.mode==2 and button.timer==button.delay+1 then button.state=not button.state end
			end
		end,
		---@endsection
		---@section drawButtons_onlyFill

		---is for complex shapes, no text
		---draws the buttons, all, according to their data
		---only works when you feed it no empty buttons, it has no failcheck
		---is purely for character optimization
		---@param complexButtons table
		drawButtons_onlyFill=function(complexButtons)
			for i,button in pairs(complexButtons) do
				if button.active then
					sC(HSV(tu(button.state and button.onHSVa or button.offHSVa)))
					drawTriangulatedPolygonF(button.triangles)
				end
			end
		end,
		---@endsection
		---@section drawButtons_onlyOutline
	
		---is for complex shapes, no text
		---draws the buttons, all, according to their data
		---only works when you feed it no fill buttons, it has no failcheck
		---is purely for character optimization
		---@param complexButtons table
		drawButtons_onlyOutline=function(complexButtons)
			for i,button in pairs(complexButtons) do
				if button.active then
					sC(HSV(tu(button.state and button.onHSVa or button.offHSVa)))
					drawPolygon(button.vertices)
				end
			end
		end,
		---@endsection
		---@section drawButtons

		---is for complex shapes, no text
		---draws the buttons, all, according to their data
		---works with both outlines and filled buttons
		---is expensive in characters and probably CPU
		---@param complexButtons table
		drawButtons=function(complexButtons)
			for i,button in pairs(complexButtons) do
				if button.active then
					sC(HSV(tu(button.state and button.onHSVa or button.offHSVa)))
					if button.fill and #button.triangles>0 then
						drawTriangulatedPolygonF(button.triangles)
					elseif not button.fill and #button.vertices>0 then
						drawPolygon(button.vertices)
					end
				end
			end
		end,
		---@endsection
		---@section createButton

		---creates a button that you can later access by buttons.['name'].state for example
		---you can leave triangles, or vertices, empty as {} if you won't use the corresponding fill=true/false functionality
		---@param name string
		---@param buttons table
		---@param triangles table { { {x1,y1},{x2,y2},{x3,y3} },{ {x1,y1},{x2,y2},{x3,y3} } }
		---@param vertices table {{x,y},{x,y},{x,y}}
		---@param onHSVa table {hue,saturavion,value,alpha}
		---@param offHSVa table {0-359,0-1,0-1,0-1}
		---@param mode integer 0 for pulse 1 for push 2 for toggle
		---@param delay integer delay change of states by many ticks
		---@param fill boolean draw filled or empty
		createButton=function(name,buttons,triangles,vertices,onHSVa,offHSVa,mode,delay,fill)
			buttons[name]={
				triangles=triangles,
				vertices=vertices,
				--only triangles can be filled, only vertices can make outline
				--you don't have to fill in the values if you know your button is always, or never, filled
				onHSVa=onHSVa,
				offHSVa=offHSVa,
				mode=mode,
				delay=delay,
				fill=fill,
				active=true,
				state=false,
				timer=0,
			}
		end,
		---@endsection
	},
	---@endsection COMPLEXCLASS

	---@section buttonTemplate
	---@diagnostic disable:undefined-global
	buttonTemplate=function()
		local buttons, complexButtons,buttonClicked
		buttons={
			['clicker']={
				x=positionx,
				y=positiony,
				w=width,
				h=height,
				onHSVa={hue,saturation,value,alpha},
				offHSVa={0-360,0-1,0-1,0-1},
				txtHSVa={},
				mode=1, --0 for pulse, 1 for push, 2 for toggle
				delay=0, --delay the activation by this much
				fill=true, --draw filled or not
				active=true, --to enable or disable drawing (and touch detection), useful when there's a lot of buttons to reduce lag
				txt='click me lick me',
				state=false, --
				timer=0
			},
			licker={}
		}

		complexButtons={
			['clicker']={
				triangles={{{x1,y1},{x2,y2},{x3,y3}},{{x1,y1},{x2,y2},{x3,y3}}},
				vertices={{x,y},{x,y},{x,y}},
				--only triangles can be filled, only vertices can make outline
				--you don't have to fill in the values if you know your button is always, or never, filled
				onHSVa={0,0,0,0},
				offHSVa={0,0,0,0},
				mode=0,
				delay=0,
				fill=true,
				active=true,
				state=false,
				timer=0,
			},
			licker={}
		}
		--example output
		buttonClicked=buttons['licker'].state
	end
	---@diagnostic enable:undefined-global
	---@endsection

}
---@endsection BUTTONCLASS

---@section copyTable
function copyTable(copyFrom)
	local copyTo={}
	for i,v in pairs(copyFrom) do
		copyTo[i]=v
	end
	return copyTo
end
---@endsection

---@section clamp
function clamp(minimum,maximum,x) return max(min(maximum,x),minimum) end
--clamp=function(mini,maxi,x) return max(min(maxi,x),mini) end
---@endsection

---@section av
---EWMA, lowkey rolling average
function av(old,new,smt) return ((smt-1)*old+new)/smt end
---@endsection

---@section av2
---EWMA, loewkey rolling average, but stays constant and new is a change
function av2(old,new,smt) return (smt*old+new)/smt end
---@endsection

---@section createRollingAverage
function createRollingAverage(smoothing)
	return {
		smoothing=smoothing,
		memory={},
		addTo=function(self, value)
			ti(self.memory,value)
			while #self.memory>self.smoothing do
				tr(self.memory,1)
			end
		end,
		getAverage=function(self)
			local av,count=0,0
			for i,v in ipairs(self.memory) do
				av=av+v
				count=count+1
			end
			return av/count
		end
	}
end
---@endsection

---@section lerp

---linearly interpolate X between {x1,y1} and {x2,y2}
function lerp(x,x1,y1,x2,y2)
	return (x-x1)*(y2-y1)/(x2-x1)+y1
end
---@endsection

---@section PID
---PID, cheap future prediction, clamped, provide with own table for memory
function PID(setpoint,variable,p,i,d,memory,mini,maxi)
	local err=setpoint-(variable+d*(variable-(memory[1] or 0)))
	memory[1]=variable
	memory[2]=clamp(mini/i,maxi/i,(memory[2] or 0)+err)
	return clamp(mini,maxi,err*p+memory[2]*i)
end
---@endsection
---@section createPID
function createPID(p,i,d,minvalue,maxvalue,smoothing)
	return {
		p=p,
		i=i,
		d=d,
		mini=minvalue,
		maxi=maxvalue,
		smoothing=smoothing,
		last=0,
		integral=0,
		runPID=function(self,setpoint,variable)
			local err=setpoint-(variable+self.d*(variable-(self.last)))
			self.last=variable
			self.integral=clamp(self.mini/self.i,self.maxi/self.i,self.integral+err)
			return err*self.p+self.integral*self.i
		end
	}
end
---@endsection
---@section getMatrix

---made by quale, that's so yikes I couldn't do it myself, roll tilt sensor facing to the right, pitch tilt sensor facing to the front, upright tilt sensor facing up, compass sensor facing the direction of motion
function getMatrix(roll,pitch,upright,compass)
    local x,y,z,a,c,s,m=sin(2*pi*roll),sin(2*pi*pitch),sin(2*pi*upright),2*pi*compass
    m=(x*x+z*z)^0.5
    m={z/m,0,-x/m;-y*x/m,m,-y*z/m;x,y,z}
    c=cos(a)
    s=sin(a)
    for j=1,3 do m[j],m[j+3]=c*m[j]-s*m[j+3],s*m[j]+c*m[j+3]end
    return m
end
--get a matrix of the vessel orientation, x/right, y/forward, z/up

---@endsection

---@section vehicleToWorld

---change vehicle relative XYZ to world relative XYZ, unadjusted for vehicle position, xy map z alt
function vehicleToWorld(x,y,z,matrix)
	return matrix[1]*x+matrix[2]*y+matrix[3]*z,matrix[4]*x+matrix[5]*y+matrix[6]*z,matrix[7]*x+matrix[8]*y+matrix[9]*z
end
---@endsection

---@section worldToVehicle

---change world relative XYZ to vehicle relative XYZ, unadjusted for vehicle position, xy map z alt
function worldToVehicle(x,y,z,matrix)
	return matrix[1]*x+matrix[4]*y+matrix[7]*z,matrix[2]*x+matrix[5]*y+matrix[8]*z,matrix[3]*x+matrix[6]*y+matrix[9]*z
end
---@endsection

---@section encode

---encodes a number into a string
function encode(toCode,coder,length,zeroToOneRange)
	local t,b,coderLen,coded,a={},'',coder:len()
	coded=zeroToOneRange and (toCode*(coderLen^length-1))//1 or toCode
	for i=1,length do
		a=(coderLen^(length-i))
		ti(t,coded//a)
		coded=coded-(coded//a)*a
	end
	for i,v in ipairs(t) do
		b=b..coder:sub(v+1,v+1)
	end
	return b
end
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
function decode(todecode,coder,zeroToOneRange)
	local coderLen,length,a,v=coder:len(),todecode:len(),0
	for i=1,length do
		v=coder:find(todecode:sub(i,i),1,true)-1
		a=a+v*coderLen^(length-i)
	end
	return zeroToOneRange and a/(coderLen^length-1) or a
end
---@endsection

---@section fitPoly

---very resource expensive, the more data you have the worse it is, but it does a decent fit, progressively gets better, parabolas are order 2, data table {{x,y},{x,y}} that you want to fit, speed how many paths it checks per call, provide with memory table, returns table of a polynomial {a0,a1,a2}
function fitPoly(order,data,speed,memorytable)
	--[[
	data is {{x,y},{x,y},{x,y}}
	coefficients are An * x ^ (n-1) so coef1 + coef2*x + coef3*x^2
	returns coefs ("b" or "mem[4]") as a table, can be called as void to just do the calcs without reporting coefficients, whole point of "memorytable"
	function error() measures the total (not average) squared errors of fed polynomial coefficients "test" to the "data" points
	errors() can be called from outside? apparently, it's ducking weird it takes no argument for data cuz it's only used inside wtf, don't please
	it also determines what the coefficients are, because all that the rest is doing really is just adjusting the coefficients to get smallest error
	since "b=mem[4]" makes one table with 2 names, I can not have to constantly set mem[4] to b and then redo it next iteration, b literally is mem[4]
	and so, set() is no more, less characters and less wasted resources
	"a" are temporarily checked coefs, b is saved best coefs
	"b" is used inside of code for faster operation because less table, eventho it's saved in mem[4]
	order is 1 less than amount of coefficients, or - it is the order/degree of the polynomial
	for example 2nd order polynomial, a squared function, a parabola, has 3 coefficients f = c + bx + ax^2 (you'll see why this order matters)
	"mem" ("memorytable") is used to keep it's values across calls unless order changes or something inside is deleted, because this is very much an iterative function
	it is not used inside loops for performance, can be used to get some data out of the inner workings like stepsize, error, or completed iterations
	please don't touch, these are for reading out:
	mem[1] is completed iterations counter, it counts how many times it already updated the "B"/"mem[4]"/"coefficients", no name cuz it's useless and it's only statistical
	mem[2] or "step" is step size and it tends to go down rather than up cuz else it gets stucks or ducks around
	oh and btw "step" can wind down... a ducking lot, if you let it run on something simple and then give it a real work...
	well it's gonna take it's sweet time to increase the step size from something like 10^-200 so... in that case you can change "memorytable[2]" from outside
	it has protection to not become a 0 in which case it would just become yikes'ed but it can still wind down a lot
	mem[3] or "err1" is error of the best coefficients
	"err2" is temporary error of "a" coefficients which constantly change and there's no point in saving it, it's to measure what's better
	these are important for the mechanics of function and really shouldn't be touched:
	mem[4] is used to keep coefficients / "b"
	mem[5] or "k" makes sure it always starts from where it ended, cuz...
	it tries "speed" times new coefficients, to make performance steady, and "speed" doesn't have to be 3^poly-order
	mem[6] or "m" checks if it has gone through 3^order paths to then lower the step size cuz it didn't find a good path
	c is %(3^d) because it can affect each coefficient 3 ways, increase, deacrease, or leave, and we don't want runaway values to go up to infinity so modulo is used
	"k" is the current path checked	
	it first generates it's own zero coefficients, then works up
	]]
	local a,b,mem,c,m,step,err1,err2,k={},{},memorytable
	local errors=function(test)
		local err,y=0
		for i,v in ipairs(data) do
			y=0
			for j,a in ipairs(test) do
				y=y+a*v[1]^(j-1)
			end
			err=err+(v[2]-y)^2
		end
		return err
	end
	if #mem~=6 or #mem[4]~=order+1 then
		--[[for i=1,6 do
			mem[i]=1
		end
		mem[4]={}]]
		mem={0,1,math.huge,{},0,0}
		for i=1,order+1 do
			mem[4][i]=0
		end
	end
	step=mem[2]
	b=mem[4]
	err1=errors(b)
	k=mem[5]
	m=mem[6]
	c=3^(order+1)
	for i=1,speed do
		m=m+1
		if m>c then step,m=step*math.random(),1 end
		k=k+1
		for j=1,#b do
			a[j]=b[j]+step*(k//3^(j-1)%3-1)
		end
		err2=errors(a)
		if err2<err1 then
			err1=err2
			k=k-1
			for i=1,#b do
				b[i]=a[i]
			end
			step=step*1.1
			mem[1]=mem[1]+1
			m=0
		end
	end
	mem[2]=step>0 and step or 1
	mem[3]=err1
	mem[5]=k
	mem[6]=m
	return b
end
---@endsection
---@section fitPolyCustom

---very resource expensive, the more data you have the worse it is, but it does a decent fit, progressively gets better, parabolas are order 2, data table {{x,y},{x,y}} that you want to fit, speed how many paths it checks per call, provide with memory table, returns table of a polynomial {a0,a1,a2}
function fitPolyCustom(amtOfCoefs,data,errorFunction,speed,memorytable)
	--[[
	data is {{x,y},{x,y},{x,y}}
	errorFunction(coefficients,data)
	is same as fitPoly but takes in a custom error function
	one more butt: order is amount of coefficienst, not the order of polynomial because well it no longer is set to polynomial
	]]
	local a,mem,c,m,step,err1,err2,k,b={},memorytable
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
	step,err1,b,k,m=mem[2],errorFunction(mem[4],data),mem[4],mem[5],mem[6]
	--err1=errorFunction(b,data)
	c=3^amtOfCoefs
	for i=1,speed do
		m=m+1
		if m>c then step,m=step*math.random(),1 end
		k=k+1
		for j=1,#b do
			a[j]=b[j]+step*(k//3^(j-1)%3-1)
		end
		err2=errorFunction(a,data)
		if err2<err1 then
			err1=err2
			k=k-1
			for i=1,#b do
				b[i]=a[i]
			end
			step=step*1.1
			mem[1]=mem[1]+1
			m=0
		end
	end
	mem[2],mem[3],mem[5],mem[6]=step>0 and step or 1,err1,k,m
	return b
end
---@endsection

---@section drawPolygon
---draws lines from vertice to vertice, order matters, table {{x,y},{x,y}...}
function drawPolygon(polygon)
    for i=0,#polygon-1 do
        local current,next=polygon[(i%#polygon)+1],polygon[((i+1)%#polygon)+1]
        dL(current[1],current[2],next[1],next[2])
    end
end
---@endsection

---@section drawTriangulatedPolygonF

---draws triangles that are outputted by triangulatePolygon, table {{{x,y},{x,y},{x,y}},...}
function drawTriangulatedPolygonF(triangles)
    for i,triangle in ipairs(triangles) do
        dTrF(triangle[1][1],triangle[1][2],triangle[2][1],triangle[2][2],triangle[3][1],triangle[3][2])
    end
end
---@endsection

---@section drawPixelArt

---art is in a form of a table{line,line,line}, whole lines are encoded binarily into a single integer
function drawPixelArt(x,y,art)
    for i=1,#art do
        local temp,exp=art[i]
        while temp>0 do
            exp=math.log(temp,2)//1
            temp=temp-2^exp
            dL(x+exp,y+i-1,x+exp+1,y+i-1)
        end
    end
end
---@endsection

---@section drawTextWrapped
function drawTextWrapped(x,y,width,txt)
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
        dT(dx,y,temp)
        dx=dx+length*5
    until #txt==0
end
---@endsection

---@section triangulatePolygon

---not quite efficient and not very compact, but can be a preprocessing generator I suppose, table {{x,y},{x,y}...}, return table { { { x1 , y1 } , { x2 , y2 } , { x3 , y3 } } , { { } , { } , { } } , triangle...}
function triangulatePolygon(vertices)
	local triangles,temp,triangle,error,temp2={},{}
	for i=1,#vertices do
		temp[i]=vertices[i]
	end
	::replay::
	x1,y1=temp[#temp][1],temp[#temp][2]
	for i=1,#temp do
		x2,y2=temp[i][1],temp[i][2]
		x3,y3=temp[i%#temp+1][1],temp[i%#temp+1][2]
		x,y=(x1+x2+x3)/3,(y1+y2+y3)/3
		triangle={{x1,y1},{x2,y2},{x3,y3}}
		temp2={}
		for j,v in ipairs(temp) do
			temp2[j]={v[1],v[2]}
		end
		for j=#temp2,1,-1 do
			error=false
			for k,v in ipairs(triangle) do
				if temp2[j][1]==v[1] and temp2[j][2]==v[2] then error=true end
			end
			if error then table.remove(temp2,j) end
		end
		error=x1==x2 and x2==x3 or y1==y2 and y2==y3
		if inPolygon(x,y,temp) then
			for j,v in ipairs(temp2) do
				error=error or inPolygon(v[1],v[2],triangle)
			end
			if not error then
				table.insert(triangles,triangle)
				table.remove(temp,i)
				goto replay
			end
		end
		x1,y1=x2,y2
	end
	return triangles
end
---@endsection

---@section inBox
function inBox(x,y,x1,y1,x2,y2) return (x>=x1 and x<=x2 or x>=x2 and x<=x1) and (y>=y1 and y<=y2 or y>=y2 and y<=y1) end
---@endsection

---@section inPolygon

---table {{x,y},{x,y}} vertices of a polygon, order matters, assumes that walls go from vertice to vertice and connects first and last vertices
function inPolygon(x,y,poly)
	local j,intersections,x1,y1,x2,y2,a,b,treshold=#poly,0
	for i=1,#poly do
		x1,y1,x2,y2=poly[i][1],poly[i][2],poly[j][1],poly[j][2]
		a=(y1-y2)/(x1-x2)
		b=y1-a*x1
		treshold=(y-b)/a
		if y>y1 and y<=y2 or y<=y1 and y>y2 then
			intersections=(x1==x2 and x<=x1 or x1~=x2 and treshold>=x) and intersections+1 or intersections
		end
		j=i
	end
	return intersections%2==1
	--[[
	x, y is the point you want to check for
	poly is a table as follows {{x,y},{x,y},{x,y}} where x,y are vertices
	]]
end
---@endsection


---@section HSV

---changes HSV into RGB and corrects it's gamma for the filfthy SW displays, hue 0-359 (360 wraps), s v alpha 0-1, suggested gamma 2.4 k 0.85, return r,g,b,a
function HSV(h,s,v,alpha) 
	local alpha,c,i,d,x,m=alpha or 1,v*s,flr((h%360)/60)+1
	x,m=c*(1-abs((h/60)%2-1)),v-c
	d={{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}}
	--return (d[i][1]+m)^a*255,(d[i][2]+m)^a*255,(d[i][3]+m)^a*255
	return correctRGBA((d[i][1]+m)*255,(d[i][2]+m)*255,(d[i][3]+m)*255,alpha*255)
	--[[
	suggested gamma and k, especially for monitor use, is 2.4 and 0.85, but I leave it open just in case
	returns r,g,b as "free" values, not in a table, also doesn't force screen.setColor, just returns so you can use r,g,b=HSV()
	]]
end
---@endsection

---@section correctRGBA

---correct for filthy SW displays, range 0-255, returns r,g,b,a
function correctRGBA(r,g,b,a)
	local gamma,k=2.4,0.85
	return 255*(k*r/255)^gamma,255*(k*g/255)^gamma,255*(k*b/255)^gamma,255*(k*a/255)^gamma
end
---@endsection

---@section Dial

---draws a dial, arc in degrees, aspect is height/width (circle/elipse), rotation offset, reverse is bool to change direction, aliasting is a number
function Dial(cenx,ceny,radius,minvalue,maxvalue,value,marks,arc,aspect,rotation,reversed,aliasing,H,S,V)
	local rot,x,y,d,x1,y1,x2,y2,an,r,g,b,a=rotation,cenx,ceny,arc,1/(maxvalue-minvalue)
	local findPos=function(x,y,radius,angle)
		local r1,r2=radius/max(1,aspect),radius/max(1,1/aspect)
		return x+cos(rot)*r1*cos(angle)-sin(rot)*r2*sin(angle),y+sin(rot)*r1*cos(angle)+cos(rot)*r2*sin(angle)
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
		r,g,b,a=HSV(H,S,V,-255*abs(2*j/aliasing-1)+255)
		--sC(r,g,b,-255*abs(2*j/aliasing-1)+255)
		sC(r,g,b,a)
		for i=-marks,marks do
			x1,y1=findPos(x,y,r0,d*i/marks/2-pi)
			dL(x1,y1,x2,y2)
			x2,y2=x1,y1
		end
		for i=-marks,marks,2 do
			x1,y1=findPos(x,y,r0+2,d*i/marks/2-pi)
			x2,y2=findPos(x,y,r0-3,d*i/marks/2-pi)
			dL(x1,y1,x2,y2)
		end
		x1,y1={},{}
		x1[1],y1[1]=findPos(x,y,r0-5,an+pi)
		for i=-1,1 do
			x1[i+3],y1[i+3]=findPos(x,y,r0/(3+abs(i)),an+pi*(2+i/2))
		end
		for i=1,4 do
			dL(x1[i],y1[i],x1[i%4+1],y1[i%4+1])
		end
	end
end
---@endsection

---@section Ballistics2D

---optimized physics simulation to eyeball the required elevation, no speed correction nor leading, elev in radians, velocity of gun in m/s, lifetime in ticks, drag as posted by devs, indirect fire is a bool, returns a radian, can't reach bool and flighttime in ticks
function Ballistics2D(x,y,elevation,velocity,drag,lifetime,indirect)
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
	e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or clamp(-pi/2,pi/2,e+(atan(ty/tx)-atan(y/x))/(indirect and -200000/tx or 3))
	return e,bad,t,((tx-x)^2+(ty-y)^2)^0.5
end
---@endsection

---@section Ballistics

---optimized physical simulation, world relative, has correction for vehicle speed but no built in leading, returns flight time for that, vehicle {{position},{speed}} in m and m/s, {x,y,z}, target {x,y,z}, iteratively adjusts azim and elev in radians world relative 0 for north and level (outputs in same manner, you feed it back in for next iteration), gun {velocity,drag,lifetime}, indirect boolean, returns azimuth, elevation, flighttime in ticks, miss radius in meters (never 0), boolean can't reach
function Ballistics(vehicle,target,azim,elev,gun,indirect)
	local a,e,v,t,h,vh,bad=azim,elev,vehicle,target
	local ix,iy,iz,vx,vy,vz=v[1][1],v[1][2],v[1][3],v[2][1],v[2][2],v[2][3]
	local x,y,z=ix,iy,iz
	local tx,ty,tz=t[1],t[2],t[3]
	local v,d,l,g,step=gun[1],1-gun[2],gun[3],30/3600,1
	local th,t=((tx-ix)^2+(ty-iy)^2)^0.5,0
	vx,vy,vz=(vx+v*sin(a)*cos(e))/60,(vy+v*cos(a)*cos(e))/60,(vz+v*sin(e))/60
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
	v,d=atan(tx-ix,ty-iy),atan(x-ix,y-iy) 
	a=((a+v-d)%(2*pi)+3*pi)%(2*pi)-pi
	--e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or min(pi/2,max(-pi/2,e+(atan((tz-iz)/th)-atan((z-iz)/h))/(indirect and -200000/th or 3)))
	--min(pi/2,max(-pi/2,e+(atan((tz-iz)/th)-atan((z-iz)/h))/(indirect and -200000/th or 3)))
	e=(e==pi/2 or -e==pi/2) and (indirect and pi/3 or 0) or clamp(-pi/2,pi/2,e+(atan((tz-iz)/th)-atan((z-iz)/h))/(indirect and -200000/th or 3))
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
end
---@endsection