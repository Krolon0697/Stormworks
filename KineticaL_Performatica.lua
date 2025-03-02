

---@section KL_Performatica 1 KL_PERFORMATICACLASS
KineticaL.KL_Performatica={

	---@section KL_wait
	---cannot be used in game
	---@param time number time to wait
	---@param unit number|nil 60 for minute, 0.001 for ms etc, defaults to 1 (seconds) 
	KL_wait=function(time,unit)
		local clock=os.clock
		local start=clock()
		local finish=time*(unit or 1)
		repeat until clock()-start>=finish
	end,
	---@endsection

	---@section KL_create_Profiler
	---not to be used in a game, will error out, returns an useful self-contained object to time shtuff, all inputs are only to set a default
	---@param txt string|nil this will be printed together with time, leave nil for no print
	---@param print_flag boolean|nil this will denote whether to print
	---@param repetitions number|nil if present it'll scale the time to be per repetition
	---@param calculate_hertz number|boolean|nil if true an additional formatting of achievable frequency will be appended 
	---@param append_colon boolean|nil if true a colon will be appended after txt and before time
	---@param minimum_txt_length number|nil if present ensures that txt is of certain length to have times in line
	---@return table object with methods
	KL_create_Profiler=function(txt,print_flag,repetitions,calculate_hertz,append_colon,minimum_txt_length)
		local times={
			{'d',86400,false},
			{'h',3600,false},
			{'min',60,false},
			{'s',1,false}, --is 's'econd, unit 1, can't have decimals
			{'ms',0.001,true},
			{'us',0.000001,true},
			{'ns',0.000000001,true},--1 clock cycle at 1GHz takes 1ns
			{'ps',0.000000000001,true},--probably redunant
		}
		local freqs={
			{'Ghz',1000000000,true},
			{'MHz',1000000,true},
			{'KHz',1000,true},
			{'Hz',1,true},
			{'mHz (slow)',1,true}
		}
		local clock=os.clock
		local format=string.format
		local rep=string.rep
		local floor=math.floor

		local function formatText(t,hertz)
			local freq=1/t
			local isFirst,txt,unit,firsthit,bignum,num,num_flr,lim=true,''
			local error='not enough repetitions to measure time!'
			local function getTimes()
				num=t/unit
				num_flr=floor(num)
			end
			local function getInteger(position)
				local v=floor(num)
				v=isFirst and tostring(v) or format(position<5 and '%02.0f' or '%03.0f',v)
				bignum=#v
				return v
			end
			local function getDecimals(position,tab)
				local v=tostring(num%1)
				if firsthit==lim and num<1 then
					v=v:sub(3,v:find('[1-9]')+1)
					return '.'..v
				end
				v=v:sub(3,5-bignum)
				return (t<unit or not tab[position][3] or #v==0) and '' or '.'..v
			end
			local function halt(position)
				local v=num_flr
				v=	v>0 and position>4 or
					firsthit==1 and position>2 or
					firsthit==2 and position>3
				return v-->0 and position>4 or position-(firsthit or (1/0))>0
			end
			local function canWork(i)
				return num_flr>0 or firsthit or i==lim and num~=0
			end
			local function subTime()
				t=t-unit*num_flr
			end

			lim=#times
			for i,v in LKipairs(times) do
				unit=v[2]
				getTimes()
				if canWork(i) then
					firsthit=firsthit or i
					error=nil
					txt=txt..getInteger(i)..getDecimals(i,times)..v[1]..' : '
					subTime()
					isFirst=false
				end
				if halt(i) then break end
			end
			if error then
				return error
			else
				txt=txt:sub(1,-3)
			end
			if hertz then
				txt=txt..rep(' ',15-#txt)
				t=freq/(tonumber(hertz) or 1)
				firsthit=nil
				isFirst=true
				lim=#freqs
				for i,v in LKipairs(freqs) do
					unit=v[2]
					getTimes()
					if canWork(i) then
						firsthit=i
						txt=txt..getInteger(i)..getDecimals(i,freqs)..v[1]
						break
					end
				end
			end
			return txt
		end
		return {
		txt=txt or '',
		repetitions=repetitions or 1,
		calculate_hertz=calculate_hertz,
		append_colon=append_colon,
		print_flag=print_flag,
		minimum_txt_length=minimum_txt_length or 0,
		---returns a string formatted in my timing scheme
		---@param txt string|table text to append before the time
		---@param time number|string time to format into a string
		---@param calculate_hertz number|number|nil specifies whether frequency should be appended, input number to divide (example: 60 to calculate how many times it can be done without causing physics lag)
		---@param dummy_param boolean|nil a dummy parameter to make object:format() work as well as object.format() because I have made that mistake
		---@return string formatted
		format=function(txt,time,calculate_hertz,dummy_param)
			if LKtype(txt)=='table' then
				txt=time..rep(' ',txt.minimum_txt_length-#time)..(txt.append_colon and ' :     ' or '')
				time=calculate_hertz
				calculate_hertz=dummy_param
			end
			return txt..formatText(time,calculate_hertz)
		end,
		---it starts the clock what do you expect to be commented
		---@param self table
		start=function(self)
			self.t=clock()
		end,

		---pretty cool for i=1,profiler:reps(count) do to simulatnously start loop and update repetitions
		---@param self table
		---@param repetitions number
		reps=function(self,repetitions)
			self.repetitions=repetitions
			self.t=clock()
			return repetitions
		end,

		---stops the clock and (maybe) prints the formatted time it took (but surely) returns time it took and formatted string
		---overwrites default object values
		---@param self table
		---@param txt string|nil
		---@param print_flag boolean|nil
		---@param repetitions number|nil
		---@param calculate_hertz any|nil input number to divide (example: 60 to calculate how many times it can be done without causing physics lag)
		---@param append_colon boolean|nil
		---@param minimum_txt_length number|nil
		---@return number seconds total time, not divided by the amount of repetitions specified
		---@return string times formatted as per print but returned
		stop=function (self,txt,print_flag,repetitions,calculate_hertz,append_colon,minimum_txt_length)
			local ret=clock()-self.t

			txt=txt or self.txt
			print_flag=print_flag or not print_flag and self.print_flag
			repetitions=repetitions or self.repetitions
			calculate_hertz=calculate_hertz or self.calculate_hertz
			append_colon=append_colon or self.append_colon
			minimum_txt_length=minimum_txt_length or self.minimum_txt_length

			local t=ret/repetitions
			txt=txt..rep(' ',minimum_txt_length-#txt)..(append_colon and ' :     ' or '')..formatText(t,calculate_hertz)
			if print_flag then
				print(txt)
			end
			self.t=clock()
			return ret,txt
		end,

		---not to be used in a game, will error out, prints how many miliseconds it took to execute a function, also it's a pass-through. All the values past inputs only overwrite the object's defaults
		---@param self table
		---@param func function to be measured
		---@param inputs table|nil inputs to be fed into the function measured
		---@param txt string|nil
		---@param print_flag boolean|nil
		---@param repetitions number|nil
		---@param calculate_hertz any|nil input number to divide (example: 60 to calculate how many times it can be done without causing physics lag)
		---@param append_colon boolean|nil
		---@param minimum_txt_length number|nil
		---@return table outputs a table of function's outputs
		---@return number seconds total time, not divided by the amount of repetitions specified
		---@return string times formatted as per print but returned
		profileFunction=function(self,func,inputs,txt,print_flag,repetitions,calculate_hertz,append_colon,minimum_txt_length)
			txt=txt or self.txt
			print_flag=print_flag or not print_flag and self.print_flag
			repetitions=repetitions or self.repetitions
			calculate_hertz=calculate_hertz or self.calculate_hertz
			append_colon=append_colon or self.append_colon
			minimum_txt_length=minimum_txt_length or self.minimum_txt_length
			inputs=inputs or {}
			local unpack,outputs,ret,t=table.unpack

			self:start()
			for i=2,repetitions do
				func(unpack(inputs))
			end
			outputs={func(unpack(inputs))}
			ret=clock()-self.t

			t=ret/repetitions
			txt=txt..rep(' ',minimum_txt_length-#txt)..(append_colon and ' :     ' or '')..formatText(t,calculate_hertz)
			if print_flag then
				print(txt)
			end
			self:start()
			return outputs,ret,txt
		end,
		t=clock()
		}
	end,
	---@endsection
}
---@endsection KL_PERFORMATICACLASS