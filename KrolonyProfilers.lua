---@section Profilers 1 PROFILERCLASS
Krolony.Profilers={
	---@section profileTime
	---not to be used in a game, will error out
	---@param name string this will be printed together with time
	---@param printt boolean, whether to print the output or not
	---@return table object with method
	profileTime=function(name,printt)
		return {
		t=os.clock(),
		name=name,
		printt=printt,
		---prints (if printt) the time it took from last stop() or initializing
		---@param self table
		---@return number miliseconds
		stop=function (self)
			local t=1000*(os.clock()-self.t)
			if self.printt then
				print((self.name or '')..string.format('%.0f',t)..'ms')
			end
			self.t=os.clock()
			return t
		end
		}
	end,
	---@endsection

	---@section profileFunction
	---not to be used in a game, will error out, prints how many miliseconds it took to execute a function, also it's a pass-through
	---@param func function to be measured
	---@param ... unknown parameters to be fed into function
	---@return unknown output of the function
	profileFunction=function(func,...)
		local time,outputs=os.clock()
		outputs={func(table.unpack({...}))}
		print(string.format('%.0f',1000*(os.clock()-time))..'ms')
		return table.unpack(outputs)
	end,
	---@endsection

	---@section eyeballTPS_creator
	---creates an object that you just run and it works
	---@return table object
	eyeballTPS_creator=function()
		return {
			onTick_fires=1,
			onDraw_fires={1,1,1},
			TPS=60,

			---Only outputs a number once in a while, being false otherwise. Play on capped FPS and look at the monitor. 
			---Doesn't work when you don't look at the monitor, that's why for control reasons I also decided to return false on non-update ticks. 
			--That way you can use the output as a bool check
			---@param self table
			---@param FPS_capped number
			---@param averaging_ticks number over how many ticks it averages (higher better) and how long you wait for an update
			---@return unknown updates once in averaging_ticks returns a number, returns false otherwise, important!
			run_onTick=function(self,FPS_capped,averaging_ticks)
				self.onTick_fires=self.onTick_fires+1
				local tps,check=0,0 --used for when there were no onDraw calls due to not looking at monitor
				if self.onTick_fires>=averaging_ticks then
					check=math.min(self.onDraw_fires[3],1)
					for i=1,3 do
						tps=tps+i*FPS_capped*self.onTick_fires/self.onDraw_fires[i]
						self.onDraw_fires[i]=self.onDraw_fires[(i+check)%4] or 0 --move counts 1 lower in index, reset index 3 (unless there were no onDraw calls)
					end
					self.onTick_fires=0
					self.TPS=(self.TPS+(tps^check+check-1)/6)/2^check --weights: 50% average 25% last check 17% previous check 8% oldest check
				end
				return check>0 and self.TPS
			end,
			run_onDraw=function(self)
				self.onDraw_fires[3]=self.onDraw_fires[3]+1
			end
		}
	end,
	---@endsection
}
---@endsection PROFILERCLASS