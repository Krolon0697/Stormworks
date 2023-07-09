---@diagnostic disable:unbalanced-assignments
---@section Geometry 1 GEOMETRYCLASS
Krolony.Geometry={
	---@section triangulatePolygon
	---not quite efficient and not very compact, but can be a preprocessing generator I suppose
	---@param vertices anytable {{x,y},{x,y}...}
	---@return table { { { x1 , y1 } , { x2 , y2 } , { x3 , y3 } } , { { } , { } , { } } , triangle...}
	triangulatePolygon=function(vertices)
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
	end,
	---@endsection

	---@section inBox
	---typical stormworks function, checks whether x is within x1 and x2 and whether y is withing y1 and y2
	---@param x number
	---@param y number
	---@param x1 number
	---@param y1 number
	---@param x2 number
	---@param y2 number
	---@return boolean
	inBox=function(x,y,x1,y1,x2,y2)
		return (x>=x1 and x<=x2 or x>=x2 and x<=x1) and (y>=y1 and y<=y2 or y>=y2 and y<=y1)
	end,
	---@endsection

	---@section inPolygon
	---checks whether point {x,y} is within a polygon
	---@param x number
	---@param y number
	---@param poly table {{x,y},{x,y},{x,y}...} vertices of a polygon, order matters, assumes that walls go from vertice to vertice and connects first and last vertices
	---@return boolean
	inPolygon=function(x,y,poly)
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
	end,
	---@endsection
}
---@endsection GEOMETRYCLASS
---@diagnostic enable:unbalanced-assignments