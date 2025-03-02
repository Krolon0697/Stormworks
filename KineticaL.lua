---@section KineticaL 1 KINETICALCLASS
---version 0.0.0
---developed by Krolon and his countless tears
---discord tag: krolon0697
---
---STILL WORK IN PROGRESS
---this is by all means an "early access"
---I'm tired of copypasting individual functions to discord
---library is still being actively reworked with changes happening
---
---library focusing on being fast as fuck boiiii
---comes with various utility functions
---and has many specialized usecases as well
---where possible, steps have been (overly so) taken to minimize size
---however as we all know, locals are needed for:
--- * speed
--- * safety of execution (no globals)
---some algorithms also are simply large
---for these reasons, some functions which would be just humongous
---come in S-mall and Q-uick variant
---readability and cleanliness not guaranteed
---read at your own discretion
---
---special thanks to everyone who introduced me to Stormworks lua and encouraged me along the way

local KL_ipairs,KL_pairs,KL_insert,KL_remove,KL_type=ipairs,pairs,table.insert,table.remove,type
--comment pending
KineticaL={
	---@section KL_clamp
	---more efficient than compact due to not using math.min and math.max
	---@param minimum number
	---@param maximum number
	---@param x number
	---@return number
	KL_clamp=function(minimum,maximum,x)
		return 	x>maximum and maximum or x<minimum and minimum or x
	end,
	---@endsection

	---@section KL_EWMA
	---EWMA, lowkey rolling average
	---@param old number previous smoothed number
	---@param new number number to add and smooth, output approuches new
	---@param smoothing number how strong smoothing is
	---@return number smoothed
	KL_EWMA=function(old,new,smoothing)
		return ((smoothing-1)*old+new)/smoothing
	end,
	---@endsection

	---@section KL_EWMA_additive
	---EWMA, loewkey rolling average, but stays constant and new is a change
	---@param old previous smoothed number
	---@param change number to add and smooth, output stays constant if 0
	---@param smoothing number how strong smoothing is
	---@return number smoothed
	KL_EWMA_additive=function(old,change,smoothing)
		return (smoothing*old+change)/smoothing
	end,
	---@endsection

	---@section KL_lerpX
	---linearly interpolate between {x1,y1} and {x2,y2}
	---@param x number more commonly denoted as "t", I however used x because it's better than just working in 0-1 range
	---@param x1 number 1st input
	---@param y1 number 1st output
	---@param x2 number 2nd input
	---@param y2 number 2nd output
	---@return number y output of x on line {x1,y1} {x2,y2}
	KL_lerpX=function(x,x1,y1,x2,y2)
		return (x-x1)*(y2-y1)/(x2-x1)+y1
	end,
	---@endsection

	---@section KL_lerpT
	---linearly interpolate between y1 and y2
	---@param t number control input
	---@param y1 number 1st output
	---@param y2 number 2nd output
	---@return number y linear interpolation between y1 for t=0 and y2 for t=1
	KL_lerpT=function(t,y1,y2)
		return y1+(y2-y1)*t
	end,
	---@endsection

	---@section KL_deepCopy
	---will copy the table t and all it's nested contents including tables
	---@param t table table to copy
	---@return copied table 
	KL_deepCopy=function(t)
		local check,tables,recursive='table',{}
		recursive=function(x)
			local new={}
			tables[x]=new
			for key,value in KL_pairs(x) do
				key=KL_type(key)==check and (tables[key] or recursive(key)) or key
				new[key]=KL_type(value)==check and (tables[value] or recursive(value)) or value
			end
			return new
		end
		return recursive(t)
	end,
	---@endsection

	---@section KL_joinTables
	---will append the table2 to the end of table1, changing it in the process, note that it does not deepcopy table entries
	---@param tab1 table
	---@param tab2 table
	---@param index number|nil index from which tab2 is copying starts, defaults to 1
	KL_joinTables=function(tab1,tab2,index)
		local start_pos=#tab1-(index or 1)+1
		for i=index or 1,#tab2 do
			tab1[start_pos+i]=tab2[i]
		end
	end,
	---@endsection

	---@section KL_xorShift
	---@param x integer
	---@return integer
	KL_xorShift=function(x)
		x=x~(x<<13)
		x=x~(x>>7)
		return x~(x<<17)
	end,
	---@endsection

	---@section KL_random
	---emulates math.random, call with (nil,69) to set seed to 69
	---@param m integer|nil the lower bound when n is present, otherwise is upper bound
	---@param n integer|nil upper bound
	---@return float|integer
	---@return integer
	KL_random=function(m,n)
		local seed,mask,xor,floor,x,anon=1,4294967295,KineticaL.xorShift,math.floor
		---emulates math.random, call with (nil,69) to set seed to 69
		---@param m integer|nil the lower bound when n is present, otherwise is upper bound
		---@param n integer|nil upper bound
		---@return float|integer
		---@return integer
		anon=function(m,n)
			seed=xor(seed)
			x=((seed>>16)&mask)/mask
			if m and n then
				x=floor(m+(n-m+.99999)*x)
			elseif m then
				x=floor(1+(m-.00001)*x)
			elseif n then
				seed=n
			end
			return x,seed
		end
		KineticaL.random=anon
		return anon(m,n)
	end,
	---@endsection

	---@section KL_stringToWordTable
	---cuts the string into words and returns a table as simple as
	---@param string string
	---@return table words
	KL_stringToWordTable=function(string)
		local out={}
		for v in string:gmatch('%g+') do
			KL_insert(out,v)
		end
		return out
	end,
	---@endsection

	---@section KL_createRollingAverage
	---full on, expensive, accurate average over X values, done as OOP to enhance performance
	---@param size integer how many numbers should be kept inside to average
	---@return table object with methods to use
	KL_createRollingAverage=function(size)
		return {
			size=size,
			memory={},
			internal_index=0,
			---@param self table
			---@param value number number to add
			add=function(self,value)
				local index=self.internal_index%self.size+1
				self.internal_index=index
				self.memory[index]=value
			end,
			---@param self table
			---@return number average
			getAverage=function(self)
				local av,count,size=0,#self.memory,self.size
				count=count>size and size or count
				for i=1,count do
					av=av+self.memory[i]
				end
				return av/count
			end
		}
	end,
	---@endsection

	---@section KL_createPID
	---PID object, D instead of simply trying to halt the change, here it's actually a derivative, "predicting future" for P and I
	---@param p number P gain
	---@param i number I gain
	---@param d number how many ticks in advance it predicts
	---@param minValue number clamped minimum output
	---@param maxValue number clamped maximum output
	---@return table object with method
	KL_createPID=function(p,i,d,minValue,maxValue)
		return {
			p=p,
			i=i,
			d=d,
			minValue=minValue,
			maxValue=maxValue,
			last=0,
			integral=0,
			---@param self table
			---@param setpoint number to which it tries to go
			---@param variable number which it processes
			---@return number output
			run=function(self,setpoint,variable)
				local err=setpoint-(variable+self.d*(variable-(self.last)))
				self.last=variable
				self.integral=KineticaL.Nuclea.clamp(self.minValue,self.maxValue,self.integral+err*self.i)
				return err*self.p+self.integral
			end
		}
	end,
	---@endsection

	---@section KL_createPID_d_of_d
	---PID object, D instead of simply trying to halt the change, here it's actually a second derivative, "predicting future" for P and I
	---@param p number P gain
	---@param i number I gain
	---@param d number how many ticks in advance it predicts
	---@param minValue number clamped minimum output
	---@param maxValue number clamped maximum output
	---@return table object with method
	KL_createPID_d_of_d=function(p,i,d,minValue,maxValue)
		return {
			p=p,
			i=i,
			d=d,
			minValue=minValue,
			maxValue=maxValue,
			last=0,
			d1_last=0,
			integral=0,
			---@param self table
			---@param setpoint number to which it tries to go
			---@param variable number which it processes
			---@return number output
			run=function(self,setpoint,variable)
				local error,d1=setpoint-variable,variable-self.last
				error=error-self.d/2*(d1*(self.d+1)-self.d1_last*(-self.d+1))
				self.d1_last=d1
				self.last=variable
				self.integral=KineticaL.clamp(self.minValue,self.maxValue,self.integral+error*self.i)
				return error*self.p+self.integral
			end
		}
	end,
	---@endsection

	---@section KL_createCaseSequential
	---@param default function|nil
	---@param ... function
	---@return table cases
	KL_createCaseSequential=function(default,...)
		local case={...}
		case.default=default or function() print("i'm default") end
		case.run=function(self,case,...)
			return (self[case] or self.default)(...)
		end
		return case
	end,
	---@endsection

	---@section KL_createCaseLabeled
	---be careful as this one requires fields default, case 1 label, case 1 function, case 2 label, case 2 function
	---@param default function|nil
	---@param ... any
	---@return table cases
	KL_createCaseLabeled=function(default,...)
		local labels,case={...},{}
		case.default=default or function() print("i'm default") end
		case.run=function(self,case,...)
			return (self[case] or self.default)(...)
		end
		for i=1,#labels,2 do
			case[labels[i]]=labels[i+1]
		end
		return case
	end,
	---@endsection

	---@section KL_createStack 1 KL_STACKCLASS
	---@return table stack
	KL_createStack=function()
		return {
			n=0,
			---@section KL_push
			---@param self table
			---@param val any
			KL_push=function(self,val)
				self.n=self.n+1
				self[self.n]=val
			end,
			---@endsection

			---@section KL_pop
			---@param self table
			---@return any value at stack
			KL_pop=function(self)
				local check=self.n>0
				self.n=check and (self.n-1) or 0
				return check and self[self.n+1]
			end,
			---@endsection

			---@section KL_size
			---@param self table
			---@return number
			KL_size=function(self)
				return self.n
			end,
			---@endsection

			---@section KL_checkNotEmpty
			---@param self any
			---@return boolean
			KL_checkNotEmpty=function(self)
				return self.n>0
			end,
			---@endsection

			---@section KL_peek
			---peeks at the value (pos) from the top, 0 is top, 1 is below top and so on
			---@param self table
			---@param pos number int
			---@return any value at stack
			KL_peek=function(self,pos)
				pos=pos or 0
				return self[self.n-pos]
			end,
			---@endsection

			---@section KL_overwrite
			---overwrite a value (pos) from top
			---@param self table
			---@param pos number int
			---@param val any
			KL_overwrite=function(self,pos,val)
				self[self.n-pos]=val
			end
			---@endsection
		}
	end,
	---@endsection KL_STACKCLASS
}
local KineticaL=KineticaL --a cheeky insert helping ingame performance after the built process

require('KineticaL_Formata')		--recently updated
require('KineticaL_Graphica')		--not updated for a long long time, pending changes
require('KineticaL_Harmonica')		--not updated for a long time, pending changes
require('KineticaL_Matrixa')		--mid updating
--require('KineticaL_Minifica')		--heavy WIP
require('KineticaL_Performatica')	--pending changes
require('KineticaL_Synaptica')		--heavy WIP
require('KineticaL_Vectora')		--recently updated, still unsure of the changes
--require('KineticaL_Virtua') 		--heavy WIP

---@endsection KINETICALCLASS