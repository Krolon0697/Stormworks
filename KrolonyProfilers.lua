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
}
---@endsection PROFILERCLASS