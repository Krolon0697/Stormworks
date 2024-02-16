---@section Utilities 1 UTILITIESCLASS
Krolony.Utilities={

	---@section clamp
	---compact but not super efficient
	---@param minimum number
	---@param maximum number
	---@param x number
	---@return number
	clamp=function(minimum,maximum,x)
		return math.max(math.min(maximum,x),minimum)
	end,
	---@endsection

	---@section av
	---EWMA, lowkey rolling average
	---@param old number previous smoothed number
	---@param new number number to add and smooth, output approuches new
	---@param smt number how strong smoothing is
	---@return number smoothed
	av=function(old,new,smt)
		return ((smt-1)*old+new)/smt
	end,
	---@endsection

	---@section av2
	---EWMA, loewkey rolling average, but stays constant and new is a change
	---@param old previous smoothed number
	---@param change number to add and smooth, output stays constant if 0
	---@param smt number how strong smoothing is
	---@return number smoothed
	av2=function(old,change,smt)
		return (smt*old+change)/smt
	end,
	---@endsection

	---@section createRollingAverage
	---full on, expensive, accurate average over X values
	---@param smoothing number how many numbers should be kept inside to average
	---@return table object with methods to use
	createRollingAverage=function(smoothing)
		return {
			smoothing=smoothing,
			memory={},
			internalIndex=0,
			---@param self table
			---@param value number number to add
			add=function(self, value)
				self.internalIndex=self.internalIndex%self.smoothing+1
				self.memory[self.internalIndex]=value
			end,
			---@param self table
			---@return number average
			getAverage=function(self)
				local av=0
				for i=1,self.smoothing do
					av=av+self.memory[i]
				end
				return av/self.smoothing
			end
		}
	end,
	---@endsection

	---@section lerp
	---linearly interpolate between {x1,y1} and {x2,y2}
	---@param x number more commonly denoted as "t", I however used x because it's better than just working in 0-1 range
	---@param x1 number 1st input
	---@param y1 number 1st output
	---@param x2 number 2nd input
	---@param y2 number 2nd output
	---@return number y output of x on line {x1,y1} {x2,y2}
	lerp=function(x,x1,y1,x2,y2)
		return (x-x1)*(y2-y1)/(x2-x1)+y1
	end,
	---@endsection

	---@section createPID
	---PID object, D instead of simply trying to halt the change, here it's actually a derivative, "predicting future" for P and I
	---@param p number P gain
	---@param i number I gain
	---@param d number how many ticks in advance it predicts
	---@param minValue number clamped minimum output
	---@param maxValue number clamped maximum output
	---@return table object with method
	createPID=function(p,i,d,minValue,maxValue)
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
				self.integral=Krolony.Utilities.clamp(self.minValue,self.maxValue,self.integral+err*self.i)
				return err*self.p+self.integral
			end
		}
	end,
	---@endsection

	---@section createPID_d_of_d
	---PID object, D instead of simply trying to halt the change, here it's actually a second derivative, "predicting future" for P and I
	---@param p number P gain
	---@param i number I gain
	---@param d number how many ticks in advance it predicts
	---@param minValue number clamped minimum output
	---@param maxValue number clamped maximum output
	---@return table object with method
	createPID_d_of_d=function(p,i,d,minValue,maxValue)
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
				self.integral=Krolony.Utilities.clamp(self.minValue,self.maxValue,self.integral+error*self.i)
				return error*self.p+self.integral
			end
		}
	end,
	---@endsection

	---@section deepCopy
	deepCopy=function(t)
		local new={}
		for key,value in next,t do
			new[key]=math.type(value)=='table' and Krolony.Utilities.deepCopy(value) or value
		end
		return new
	end,
	---@endsection
}
---@endsection UTILITIESCLASS