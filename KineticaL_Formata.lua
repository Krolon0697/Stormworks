
---@section __LB_SIMULATOR_ONLY_KINETICAL_FORMATA__
local KineticaL,KL_ipairs,KL_pairs,KL_insert,KL_remove,KL_type=KineticaL,ipairs,pairs,table.insert,table.remove,type
---@endsection

---@section KL_Formata 1 KL_FORMATACLASS
---Focuses on encoding and decoding numbers into various forms, including floats, strings, integers, and tables of integers, for efficient storage, transmission, and manipulation.
KineticaL.KL_Formata={

	---@section KL_uint32ToChannel
	---@param int number 32 bit unsigned integer to encode and send over composite
	---@param channel number channel to which the data is sent
	KL_uint32ToChannel=function(int,channel)
		--[[
		1 11111110 11111111111111111111111
		l lllllllp rrrrrrrrrrrrrrrrrrrrrrr
		right has all the mantissa
		left has sign and 7 bits of of exponent
		bool has the 8th bit (reading from left) of the exponent
		parity can be used to fix something like a broken subnormal or -0 if these happen to cause issues
		so far I have not seen any issues so I've simplified to the bare minimum
		]]
		output.setNumber(channel,(('f'):unpack(('I'):pack((int&4278190080)|(int&8388607)))))
		output.setBool(channel,int&8388608~=0)
	end,
	---@endsection

	---@section KL_channelToUint32
	---@param channel number channel from which to read the data
	---@return decoded number
	KL_channelToUint32=function(channel)
		return (('I'):unpack(('f'):pack(input.getNumber(channel))))|(input.getBool(channel) and 8388608 or 0)
	end,
	---@endsection

	---@section KL_floatToInt_approxShiftAndExponent
	---@param num number float to check for the exponent and shift
	---@param referenceExpBits integer|nil can be used when one exponent is already in place to get just the shift
	---@return integer shift
	---@return integer|nil exponentBits
	KL_floatToInt_approxShiftAndExponent=function(num,referenceExpBits)
		num=((('i8'):unpack(('d'):pack(num))>>52)&2047)-1023
		local exponentBits,mask=0,0
		if referenceExpBits then
			return 2^referenceExpBits-1-num
		elseif num<=0 then
			return -num,0
		end
		repeat
			mask=(mask<<1)|1
			exponentBits=exponentBits+1
		until num&mask==num
		return mask-num,exponentBits
	end,
	---@endsection

	---@section KL_floatToInt_getNativeShiftAndExponent
	---@param bits integer the size of the floating point
	---@return integer shift
	---@return integer exponentBits
	KL_floatToInt_getNativeShiftAndExponent=function(bits)
		bits=3+bits//6
		return 2^(bits-1)-1,bits
	end,
	---@endsection

	---@section KL_floatToInt
	---got subnormals but no infs and nans, variable shift and exp bits, can toggle off sign bit, enforce classic conversion
	---@param float number float to store in an int
	---@param bits number float format, mini8, half16, float32, double64 and anything inbetween
	---@param custom_exponentBits nil|number can be used to force a certain range regardless of standard formats (allows bfloat, tensorfloat)
	---@param custom_shift nil|number overrules the halfshift of floats to shift the range towards more low end precision or larger numbers
	---@param custom_unsigned nil|boolean flag to use unsigned format, extra bit goes to mantissa, messes up everything, don't use unless you know what you're doing
	---@param custom_forceDouble nil|boolean flag to always use lua string pack unpack to convert numbers
	---@param custom_disableDouble nil|boolean flag to disable automatic lua string pack unpack conversion when there's more than 42 bits
	---@return integer
	KL_floatToInt=function(float,bits,custom_exponentBits,custom_shift,custom_unsigned,custom_forceDouble,custom_disableDouble)
		--[[
		according to my (brute force) testing float32 is fully representible
		(with the exception of NaNs and infs)
		I remember seeing issues when mantissa was getting up to around 40 bits however
		probably numerical instability in lua double
		hence for sizes above 42 when mantissa would grow beyond 32 bits (plenty of safe space)
		it defaults to string pack upack using doubles
		also at that point the exponent is already 10 bits, just 1 shy of double's 11 so why not

		notable sizes for bytes assuming default settings:
			8 - minifloat	4 bit exp, 3 bit mant, largest num 480
			16 - half 		5 bit exp, 10 bit mant, largest num 131008
			24 - AMD's fp24	7 bit exp, 16 bit mant, largest num 3.679e+10, twice the precision of uint16 (unsigned short)
			32 - float		8 bit exp, 23 bit mant, largest num 6.805e+38 (twice the range of normal float because no inf/nan)
			40 - no format	9 bit exp, 30 bit mant, largest num 2.315e+77 full precision of signed int32 and increased range
			43 and above defaults to 11 bit exp using lua double format (truncated mantissa)
		notable sizes for char usage (multiples of 6)
			6	-	4 bit exp, 1 bit mant, largest num 384, very very bad precision
			12	-	5 bit exp, 6 bit mant, largest num 130048
			18	-	6 bit exp, 11 bit mant, largest num 8587837440
			24	-	AMD's fp24	7 bit exp, 16 bit mant, largest num 3.679e+10, twice the precision of uint16 (unsigned short)
			30	-	8 bit exp, 21 bit mant, largest num 6.805e+38
			36	-	9 bit exp, 26 bit mant, largest num 2.315e+77
			42	-	10 bit exp, 31 bit mant, largest num 2.681e+154 full uint32 precision
			any size mentioned here -1 has one less bit for exponent with the same mantissa, having same precision but decreased range
			43 and above defaults to 11 bit exp using lua double format (truncated mantissa)
		]]
		if not custom_disableDouble and bits>42 or custom_forceDouble then
			--is normal double but truncated mantissa
			--+0 ensures only one return
			return ('i8'):unpack(('d'):pack(float))>>(64-bits)
		end
		local expBits,mantissa,min,max,log,mantissaBits,maxMantissa,expLow,expHigh,expShift,expRepresentation,expValue=custom_exponentBits or (3+bits//6),float<0 and -float or float,math.min,math.max,math.log
		mantissaBits=bits-expBits-(custom_unsigned and 0 or 1)
		maxMantissa=2^mantissaBits --mantissa can be this -1 but it's used as this for division
		expShift=custom_shift or 2^(expBits-1)-1 --default shift compliant with ieee
		expHigh=2^expBits-1-expShift
		expLow=-expShift --lowest possible exponent is when the representation is 0
		expValue=log(mantissa,2)//1 --get a quick and dirty approximation
		expValue=expValue+mantissa/2^expValue//1-1 --correct for inaccurate log, keep in mind mantissa at this point is abs(input)
		expValue=min(expHigh,max(expLow,expValue)) --put in range
		expRepresentation=expValue+expShift
		mantissa=min(maxMantissa-1,(mantissa/2^max(expLow+1,expValue) - min(expRepresentation,1))*maxMantissa)
		--okay a lot going on in the mantissa
		--by default mantissa/2^expValue - 1 is how the mantissa would be stored, but
		--for subnormals shit changes
		--max(expLow+1) makes it so that when exponent would be -127 (for float32) it's -126 instead
		--then, -min(expRepresentation,1) is the -1, but
		--when expRepresentation is 0, the exponent is -127 because shift, so, at 0, we don't subtract 1
		--because fuckin subnormals
		--and fuckin 0 too
		mantissa=(expRepresentation<<mantissaBits)|(mantissa+0.5)//1--is exponent and mantissa, var reuse
		--just safeguarding against encoding a -0
		return (not custom_unsigned and float<0 and mantissa~=0 and 1<<(bits-1) or 0)|mantissa
	end,
	---@endsection

	---@section KL_intToFloat
	---got subnormals but no infs and nans, variable shift and exp bits, can toggle off sign bit, enforce classic conversion, refer to float_To_Int for notable bit sizes
	---@param int number integer storing the float
	---@param bits number float format, mini8, half16, float32, double64 and anything inbetween
	---@param custom_exponentBits nil|number can be used to force a certain range regardless of standard formats (allows bfloat, tensorfloat)
	---@param custom_shift nil|number overrules the halfshift of floats to shift the range towards more low end precision or larger numbers
	---@param custom_unsigned nil|boolean flag to use unsigned format, extra bit goes to mantissa, messes up everything, don't use unless you know what you're doing
	---@param custom_forceDouble nil|boolean flag to always use lua string pack unpack to convert numbers
	---@param custom_disableDouble nil|boolean flag to disable automatic lua string pack unpack conversion when there's more than 42 bits
	---@return float
	KL_intToFloat=function(int,bits,custom_exponentBits,custom_shift,custom_unsigned,custom_forceDouble,custom_disableDouble)
		if not custom_disableDouble and bits>42 or custom_forceDouble then
			--is normal double but truncated mantissa
			--+0 ensures only one return
			return (('d'):unpack(('i8'):pack(int<<(64-bits))))
		end
		local expBits,sign,check,mantissaBits=custom_exponentBits or (3+bits//6),custom_unsigned and 1 or (-1)^(int>>(bits-1)&1)
		mantissaBits=bits-expBits-(custom_unsigned and 0 or 1)
		local mantissa,exponent=int&(2^mantissaBits-1),(int>>mantissaBits)&(2^expBits-1) --not much to say it's just reading the representation
		check=exponent==0 and 0 or 1 --that little bugger is for subnormals (and the damn 0)
		--when exponent representation is 0, the exponent is this-shift (-127 in case of float32)
		exponent=exponent - (custom_shift or 2^(expBits-1)-1)--default to -127 shift for float32
		return sign*2^(exponent+1-check)*(check+mantissa/2^mantissaBits)
		--exponent+1-check is usually just exponent, except for subnormals (and the damn 0) so it goes up from -127 to -126 (in case of float32)
		--mantissa with the subnormal check again is 1.X for normal numbers and 0.X for subnormals
	end,
	---@endsection

	---@section KL_floatToIntDry
	---basic conversion, no bells and whistles, got subnormals but no infs and nans, refer to float_To_Int for notable bit sizes
	---@param float number float to store in an int
	---@param bits number float format, mini8, half16, float32, double64 and anything inbetween
	---@return integer
	KL_floatToIntDry=function(float,bits)
		--refer to non Dry for documentation
		if bits>42 then
			return ('i8'):unpack(('d'):pack(float))>>(64-bits)
		end
		local expBits,mantissa,min,max,log,mantissaBits,maxMantissa,expShift,expRepresentation,expValue=(3+bits//6),float<0 and -float or float,math.min,math.max,math.log
		mantissaBits=bits-expBits-1
		maxMantissa=2^mantissaBits
		expShift=2^(expBits-1)-1
		expValue=log(mantissa,2)//1
		expValue=expValue+mantissa/2^expValue//1-1
		expValue=min(expShift+1,max(-expShift,expValue))
		expRepresentation=expValue+expShift
		mantissa=min(maxMantissa-1,(mantissa/2^max(1-expShift,expValue) - min(expRepresentation,1))*maxMantissa)
		mantissa=(expRepresentation<<mantissaBits)|(mantissa+0.5)//1
		return (float<0 and mantissa~=0 and 1<<(bits-1) or 0)|mantissa
		--refer to non Dry for documentation
	end,
	---@endsection

	---@section KL_intToFloatDry
	---basic conversion, no bells and whistles, got subnormals but no infs and nans, refer to float_To_Int for notable bit sizes
	---@param int number integer storing the float
	---@param bits number float format, mini8, half16, float32, double64 and anything inbetween
	---@return float
	KL_intToFloatDry=function(int,bits)
		--refer to non Dry for documentation
		if bits>42 then
			return (('d'):unpack(('i8'):pack(int<<(64-bits))))
		end
		local expBits,sign,check,mantissaBits=3+bits//6,(-1)^(int>>(bits-1)&1)
		mantissaBits=bits-expBits-1
		local mantissa,exponent=int&(2^mantissaBits-1),(int>>mantissaBits)&(2^expBits-1)
		check=exponent==0 and 0 or 1
		exponent=exponent-2^(expBits-1)+1
		return sign*2^(exponent+1-check)*(check+mantissa/2^mantissaBits)
		--refer to non Dry for documentation
	end,
	---@endsection

	---@section KL_fixedTable_encode
	---encodes an integer into smaller fixed size integers in an output table
	---@param int integer input integer
	---@param bits integer how many bits to encode it in
	---@param count integer to how many the integer is split into
	---@param out table|nil if present, appends the encoding at the end, else creates it's own table
	---@return table 
	KL_fixedTable_encode=function(int,bits,count,out)
		local t,mask,size=out or {},2^bits-1
		size=#t
		for i=size,size+count-1 do
			t[i+1]=(int>>(bits*i))&mask
		end
		return t
	end,
	---@endsection

	---@section KL_fixedTable_decode
	---decodes an integer from a table and crafts it into a bigger size original integer
	---@param tab table table with encoded data
	---@param bits integer size of each entry in the table
	---@param count integer how many entries there are per encoded integer
	---@param index integer|nil defaults to 1, the index at which to decode
	---@return integer value
	---@return integer index
	KL_fixedTable_decode=function(tab,bits,count,index)
		local int=0
		index=index or 1
		for i=0,count-1 do
			int=int|(tab[index+i]<<(bits*i))
		end
		return int,index+count
	end,
	---@endsection

	---@section KL_variableTable_encode
	---Variable Bit Sequence Encoder - encodes an int in a variable amount of bits as needed, each storing bits-1 bits and last bit reserved to denoute a continuation
	---@param int number integer
	---@param bits number integer
	---@param out table|nil if present, appends the encoding at the end, else creates it's own table
	---@return table encodedIntegers
	KL_variableTable_encode=function(int,bits,out)
		local t,mask,i=out or {},(2^bits>>1)-1
		i=#t
		bits=bits-1
		repeat
			i=i+1
			t[i]=int&mask
			int=int>>bits
		until int==0
		t[i]=t[i]|(mask+1)
		return t
	end,
	---@endsection

	---@section KL_variableTable_decode
	---decodes a variable bit sequence and outputs an integer
	---@param tab table table of ints
	---@param bits integer bits stating how many bits there are, defaults to 8 for bytes
	---@param pos integer|nil start position, defaults to 1
	---@return number integer
	---@return number position position for first non encoded value for easy chaining
	KL_variableTable_decode=function(tab,bits,pos)
		local int,iter,mask,v=0,0,(2^bits>>1)-1
		pos=pos or 1
		bits=bits-1
		repeat
			v=tab[pos+iter]
			int=int|((v&mask)<<(bits*iter))
			iter=iter+1
		until v>mask
		return int,pos+iter
	end,
	---@endsection

	---@section KL_variableString_encode
	---encodes the int into variable amount of chars each containing 5 bits, 1 bit to denote continuation vs finished value
	---@param int integer to encode in a string
	---@param str string|nil string at which the result is appended at, default empty
	---@return string str
	KL_variableString_encode=function(int,str) --Variable Five Bit Integer String Encoder
		str=str or ''
		local char,x=str.char
		repeat
			x=40+(int&31)+(int>31 and 32 or 0)
			str=str..char(x>90 and x+6 or x)
			int=int>>5
		until int==0
		return str
	end,
	---@endsection

	---@section KL_variableString_decode
	---decodes a part of the string containing 5 bits of data in each char for as long as 6th bit is set. When done it returns a string shortened by the decoded value
	---@param str string string with encoded integer
	---@param pos integer|nil position at which to start decoding, defaults to 1
	---@return integer int
	---@return string str with postions 1 through end of decoded removed and the tail remaining
	KL_variableString_decode=function(str,pos) --Five Bit Integer String Decoder
		local int,i,val=0,0
		pos=pos or 1
		repeat
			val=str:byte(pos+i)
			val=(val>90 and val-6 or val)-40
			int=int|((val&31)<<(5*i))
			i=i+1
		until val<32
		return int,str:sub(pos+i)
	end,
	---@endsection

	---@section KL_fixedString_encode
	---encodes an integer into "char_count" chars each containing 6 bits. Is of fixed size, better efficiency than VFBIS but much less flexible
	---@param int integer
	---@param char_count integer
	---@param str string|nil the string to append the encoded data to, defaults to empty string
	---@return string
	KL_fixedString_encode=function(int,char_count,str) --Static Six Bit Integer String Encoder
		str=str or ''
		local char,x=str.char
		for i=1,char_count do
			x=40+(int&63)
			str=str..char(x>90 and x+6 or x)
			int=int>>6
		end
		return str
	end,
	---@endsection

	---@section KL_fixedString_decode
	---decodes an integer from "char_count" chars each containing 6 bits. Is of fixed size, better efficiency than VFBIS but much less flexible
	---@param str string
	---@param char_count number how many characters does encoded integer occupy?
	---@param pos integer|nil position at which to start decoding, defaults to 1
	---@return integer int
	---@return string str shortened by char_count, useful for encoded arrays of data
	KL_fixedString_decode=function(str,char_count,pos) --Static Six Bit Integer String Decoder
		local int,val=0
		pos=pos or 1
		for i=0,char_count-1 do
			val=str:byte(pos+i)
			val=(val>90 and val-6 or val)-40
			int=int|((val&63)<<(6*i))
		end
		return int,str:sub(pos+char_count)
	end,
	---@endsection

	---@section KL_transcribe
	---changes a table of lets say 8 bits (bits in) into a larger output of 4 bits (bits out) and returns that. Works in any direction but when bringing back, total_out_values might be needed to prune the end
	---@param tab table
	---@param bits_in number
	---@param bits_out number
	---@param total_out_values number|nil used to trim the end when transcribing back due to edge cases and accidental 0 pads
	---@param start_pos number|nil defaults to 1, can be used to skip a header or smfn
	---@return table transcribed into different bit size
	KL_transcribe=function(tab,bits_in,bits_out,total_out_values,start_pos)
		local out,buffer,shift,insert={},0,0,table.insert
		total_out_values=total_out_values or (1/0)
		start_pos=start_pos or 1
		for i,val in ipairs(tab),tab,start_pos-1 do
			buffer=(buffer<<bits_in)|val
			shift=shift+bits_in
			while shift>=bits_out do
				local test=buffer>>(shift-bits_out)
				insert(out,test)
				test=buffer&(2^(shift-bits_out)-1)
				buffer=test
				shift=shift-bits_out
			end
		end
		while shift>0 do
			insert(out,buffer<<(bits_out-shift))
			shift=shift-bits_out
		end
		for i=total_out_values+1,#out do
			out[i]=nil
		end
		return out
	end,
	---@endsection

	---@section KL_flattenTable
	---only to be used with array-like tables, 1 indexed
	---@param tab table table to flatten
	---@param optional_func_per_entry function|nil if present, each recovered value will be put through it, useful for compression
	---@return table
	KL_flattenTable=function(tab,optional_func_per_entry)
		local out,tabtype,countConsecutiveSameType,flatten_recursive={},'table'
		optional_func_per_entry=optional_func_per_entry or function(x) return x end
		countConsecutiveSameType=function(t,pos)
			local type,count=KL_type(t[pos]),0
			repeat
				count=count+1
			until KL_type(t[pos+count])~=type
			return type,count
		end
		flatten_recursive=function(t)
			KL_insert(out,#t)
			local pos=1
			while pos<=#t do
				local type,count=countConsecutiveSameType(t,pos)
				if type==tabtype then
					KL_insert(out,(count<<1)+1)
					for i=pos,pos+count-1 do
						flatten_recursive(t[i])
					end
				else
					KL_insert(out,count<<1)
					for i=pos,pos+count-1 do
						KL_insert(out,optional_func_per_entry(t[i]))
					end
				end
				pos=pos+count
			end
		end
		flatten_recursive(tab)
		return out
	end,
	---@endsection

	---@section KL_unflattenTable
	---only to be used with array-like tables, 1 indexed
	---@param tab table table to unflatten
	---@param optional_func_per_entry function|nil if present, each recovered value will be put through it, useful for decompression
	---@return table
	KL_unflattenTable=function(tab,optional_func_per_entry)
		local recursive,out
		optional_func_per_entry=optional_func_per_entry or function(x) return x end
		recursive=function(pos)
			local t,inserted,n,header,count,subTable={},0,tab[pos]
			pos=pos+1
			while inserted<n do
				header=tab[pos]
				count=header>>1
				pos=pos+1
				if header&1==1 then
					for i=1,count do
						subTable,pos=recursive(pos)
						KL_insert(t,subTable)
					end
				else
					for i=1,count do
						KL_insert(t,optional_func_per_entry(tab[pos]))
						pos=pos+1
					end
				end
				inserted=inserted+count
			end
			return t,pos
		end

		out=recursive(1)
		return out
	end,
	---@endsection
}
---@endsection KL_FORMATACLASS