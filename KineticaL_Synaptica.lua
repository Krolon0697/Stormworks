
---@section Synaptica 1 SYNAPTICACLASS
KineticaL.Synaptica={

	AI_Creator=function()
		local nada,Nuclea,sacVec,ipairsL=nil,KineticaL.Nuclea,KineticaL.Nuclea.Vectors.newVA(),ipairs
		return {
			iterator=2,
			layers={},

			--used to initiate a blank AI
			createArchitecture=function(self,architecture)
				local previous_size,size,layer1=0
				for i,data in ipairsL(architecture) do
					size=data>>3
					self.layers[i]={
						activation=data&7,
						nodes=sacVec.newVA(size),
						bias=sacVec.newVA(size),
						weights=Nuclea.Matrices.newVM(previous_size,size),
					}
					previous_size=size
				end
				for i=#architecture+1,#self.layers do
					self.layers[i]=nil
				end
				layer1=self.layers[1]
				layer1.bias,layer1.weights,layer1.activation=nada,nada,nada
				self.input=layer1.nodes
				self.output=self.layers[#self.layers].nodes
			end,
			outputModelToString=function(self,charsPerWeight,float_mode)
				local encode=KineticaL.Cryptica.Formata.encode_SSBIS
				local txt=encode((charsPerWeight<<1)+(float_mode and 1 or 0),1)..encode(#self.layers,1)
				for i,layer in ipairsL(self.layers) do
					txt=txt..encode((layer.activation or 0)+(#layer.nodes<<3),2)
				end
				local function layerIterator()
					return ipairsL(nada),self.layers,1
				end
				if float_mode or float_mode==nil and charsPerWeight>5 then
					local absolute_max,mmax,abs=0,math.max,math.abs
					for i,layer in layerIterator() do
						for j,row in ipairsL(layer.weights) do
							for k,weight in ipairsL(row) do
								absolute_max=mmax(absolute_max,abs(weight))
							end
						end
						for j,bias in ipairsL(layer.bias) do
							absolute_max=mmax(absolute_max,abs(bias))
						end
					end

					local bits=6*charsPerWeight
					bits=bits>64 and 64 or bits
					local shift,expBits
					local junk1,expBitsRequired=KineticaL.Cryptica.Formata.approx_Exponent_And_Shift_float_To_Int(absolute_max,expBits)
					local junk2,expBitsSuggested=KineticaL.Cryptica.Formata.get_Native_Exponent_And_Shift_float_To_Int(bits)
					if expBitsSuggested>expBitsRequired then
						expBitsSuggested=expBitsSuggested-1
						expBits=(expBitsRequired+expBitsSuggested)//2
					elseif expBits>bits-2 then
						local throw_a_tantrum
						--[[
						imagine you have 6 bits for 1 char
						bits-2 is 4
						1 bit is for sign
						if you require more than 4 bits to store the exponent
						you have no bits left for mantissa
						like really bruh you wanna do that?
						worst case the exponent is out of range
						]]
						print('not enough precision to quant the model')
						throw_a_tantrum()
					else
						expBits=expBitsRequired
					end
					shift=KineticaL.Cryptica.Formata.approx_Exponent_And_Shift_float_To_Int(absolute_max,expBits)
					--[[
					this whole thing
					is to choose the a greedy but somewhat balanced custom FP format
					the more exponent the more range
					but high range is not required past storing the highest weight
					but high range is good for storing the lowest weights
					but mantissa is very fucking important
					so check how many exponent bits are required for the highest weight
					then check how many there should be natively (fp16->5, fp32->8)
					and pick a middle, but shifted down
					boom, lowering range to have more mantissa but not so much to cripple values lower than 1
					then pick the most aggressive exponent shift possible to just barely fit the highest weight
					further enhancing the low range for tiny weights
					]]

					txt=txt..encode(expBits,1)
					txt=txt..encode(shift,2)

					local floatToInt=KineticaL.Cryptica.Formata.float_To_Int
					local neg0=1<<(bits-1)
					previous_size=#self.layers[1].nodes
					for i,layer in layerIterator() do
						for j,row in ipairsL(layer.weights) do
							for k=1,previous_size do
								local try=floatToInt(row[k] or 0,bits,expBits,shift)
								try=try==neg0 and 0 or try--do not output negative 0
								txt=txt..encode(try,charsPerWeight)
							end
						end
						previous_size=#layer.nodes
						for j,bias in ipairsL(layer.bias) do
							txt=txt..encode(floatToInt(bias,bits,expBits,shift),charsPerWeight)
						end
					end
				else
					local absolute_max,max_chars,mmax,abs,ceil=0,0,math.max,math.abs,math.ceil
					for i,layer in layerIterator() do
						for j,row in ipairsL(layer.weights) do
							for k,weight in ipairsL(row) do
								absolute_max=mmax(absolute_max,abs(weight))
							end
						end
						for j,bias in ipairsL(layer.bias) do
							absolute_max=mmax(absolute_max,abs(bias))
						end
					end
					absolute_max=math.ceil(absolute_max)
					repeat
						absolute_max=absolute_max>>6
						max_chars=max_chars+1
					until absolute_max==0
					txt=txt..encode(max_chars,1)

					local mask=0
					for i=0,6*charsPerWeight-2 do
						mask=mask|(1<<i)
					end
					previous_size=#self.layers[1].nodes
					for i, layer in layerIterator() do
						local max=0
						for j,row in ipairsL(layer.weights) do
							for k,weight in ipairsL(row) do
								max=mmax(max,abs(weight))
							end
						end
						for j,bias in ipairsL(layer.bias) do
							max=mmax(max,abs(bias))
						end
						max=ceil(max)

						txt=txt..encode(max,max_chars)
						for j,row in ipairsL(layer.weights) do
							for k=1,previous_size do
								local weight=row[k] or 0
								weight=weight/max
								weight=(weight<0 and 1 or 0)|(((abs(weight)*mask+0.5)//1)<<1)
								weight=weight==1 and 0 or weight--do not output negative zero
								txt=txt..encode(weight,charsPerWeight)
							end
						end
						previous_size=#layer.nodes
						for j,bias in ipairsL(layer.bias) do
							bias=bias/max
							bias=(bias<0 and 1 or 0)|(((abs(bias)*mask+0.5)//1)<<1)
							txt=txt..encode(bias,charsPerWeight)
						end
					end
				end
				return txt
			end,
			loadModelFromString=function(self,str)
				local decode,previous_size,charsPerWeight,floatmode,layerCount,size,data,layer1,weight,bits=KineticaL.Cryptica.Formata.decode_SSBIS
				charsPerWeight,str=decode(str,1)
				layerCount,str=decode(str,1)
				floatmode,charsPerWeight=charsPerWeight&1~=0,charsPerWeight>>1
				bits=6*charsPerWeight
				bits=bits>64 and 64 or bits
				for i=1,layerCount do
					data,str=decode(str,2)
					size=data>>3
					self.layers[i]={
						activation=data&7,
						nodes=sacVec.newVA(size),
						bias=sacVec.newVA(size),
						weights=Nuclea.Matrices.newVM(0,size),
					}
				end
				for i=layerCount+1,#self.layers do
					self.layers[i]=nil
				end

				if floatmode then
					local intToFloat=KineticaL.Cryptica.Formata.int_To_Float
					local expBits,shift
					expBits,str=decode(str,1)
					shift,str=decode(str,2)
					previous_size=#self.layers[1].nodes
					for i,layer in ipairsL(nada),self.layers,1 do
						for j, row in ipairsL(layer.weights) do
							for k=1,previous_size do
								weight,str=decode(str,charsPerWeight)
								row[k]=weight~=0 and intToFloat(weight,bits,expBits,shift) or nil
							end
						end
						previous_size=#layer.nodes

						for j=1,#layer.bias do
							weight,str=decode(str,charsPerWeight)
							layer.bias[j]=intToFloat(weight,bits,expBits,shift)
						end
					end
				else
					local mask,max_chars,max=0
					for i=0,6*charsPerWeight-2 do
						mask=mask|(1<<i)
					end
					max_chars,str=decode(str,1)

					previous_size=#self.layers[1].nodes
					for i,layer in ipairsL(nada),self.layers,1 do
						max,str=decode(str,max_chars)
						for j, row in ipairsL(layer.weights) do
							for k=1,previous_size do
								weight,str=decode(str,charsPerWeight)
								row[k]=weight~=0 and max*((weight>>1)/mask)*(1-2*(weight&1)) or nil
							end
						end
						previous_size=#layer.nodes

						for j=1,#layer.bias do
							weight,str=decode(str,charsPerWeight)
							layer.bias[j]=max*((weight>>1)/mask)*(1-2*(weight&1))
						end
					end
				end

				layer1=self.layers[1]
				layer1.bias,layer1.weights,layer1.activation=nada,nada,nada
				self.input=layer1.nodes
				self.output=self.layers[#self.layers].nodes
			end,
			run=function(self,inputs)
				self.input:setToVA(inputs)
				local previous_nodes=self.layers[1].nodes
				for i,layer in ipairsL(nada),self.layers,1 do
					sacVec:matMultVA(previous_nodes,layer.weights)
					sacVec:addVA(sacVec,layer.bias)
					sacVec:activateVA(layer.activation,layer.nodes)
					previous_nodes=layer.nodes
				end
				return self.output:copyVA()
			end,
			big_run=function(self,inputs,maxOps)
				local previous_nodes,layers,iter,layer,ops=self.layers[1].nodes,self.layers,self.iterator
				layer=layers[iter]
				ops=#layer.nodes*#previous_nodes
				maxOps=maxOps or 1/0
				if iter==2 then self.input:setToV(inputs) end
				repeat
					sacVec:matMultVA(previous_nodes,layer.weights)
					sacVec:addVA(sacVec,layer.bias)
					sacVec:activateVA(layer.activation,layer.nodes)
					previous_nodes=layer.nodes

					iter=iter+1
					layer=layers[iter]
					ops=layer and ops+#layer.nodes*#previous_nodes or 0
				until ops>maxOps or not layer
				if not layer then
					iter=2
				end
				self.iterator=iter
				return self.output:copyVA(),iter==2
			end,

			score=function(self,data)
				--local errors,errors_square,error,weight,result=0,0
				--for i,data_point in ipairsL(data) do
				--	result=self:run(data_point.input)
				--	error=result:subVA(data_point.output,sacVec):magnitudeVA()
				--	weight=data_point.weight or 1
				--	errors=errors+weight*error
				--	errors_square=errors_square+weight*error^2
				--end
				local errors_square,result,weight=0
				for i,data_point in ipairsL(data) do
					result=self:run(data_point.input)
					weight=data_point.weight or 1
					for j=1,#result do
						local thefuck=weight*(result[j]-data_point.output[j])^2
						errors_square=errors_square+thefuck
					end
				end
				return errors_square
			end,

			randomTrain=function(self,data,seed,norm_strength,max_repeats)
				seed=seed or 1
				norm_strength=norm_strength or 0.25
				max_repeats=max_repeats or 100

				local rand
				do
					local int='0xFFFFFFFF'~0
					--so I'm writing this because I saw this and didn't know wtf I did
					--basically, it's 4x4 bits, or, 2^16-1, except as int so no coversions
					--I did this as 0x because it was faster than taking out a calculator
					--then ~0 to just convert to int
					--lazy and fast in execution down below
					--now I write comment
					--silly me
					--I want it to stay as that as my legacy
					local xorshift=KineticaL.Nuclea.xorShift
					rand=function()
						seed=xorshift(seed)
						return ((seed>>4)&int)/int
					end
				end
				local function applyRandomness(layer,amount)
					local norm=amount*norm_strength
					for i,row in ipairsL(layer.weights) do
						for j,v in ipairsL(row) do
							v=v+rand()*2*amount-amount
							v=v+(v>norm and -norm or v<-norm and norm or -v)
							row[j]=v
						end
					end
					for i,v in ipairsL(layer.bias) do
						v=v+rand()*2*amount-amount
						v=v+(v>norm and -norm or v<-norm and norm or -v)
						layer.bias[i]=v
					end
				end
				local function saveDeltas(layer)
					layer.biasDeltas:subVA(layer.bias,layer.savedBias)
					layer.weights:addQM(layer.savedWeights,-1,layer.weightDeltas)
					--layer.bias:subVA(layer.savedBias,layer.biasDeltas)
				end
				local function tryRepeatChange(layer,mult)
					local current,deltas,delta=layer.weights,layer.weightDeltas
					for i,row in ipairsL(current) do
						for j,v in ipairsL(row) do
							delta=deltas[i][j]*mult
							delta=v*(v+delta)>0 and delta or -v
							row[j]=v+delta
						end
					end
					current,deltas=layer.bias,layer.biasDeltas
					for i,v in ipairsL(current) do
						delta=deltas[i]*mult
						delta=v*(v+delta)>0 and delta or -v
						current[i]=v+delta
					end
				end
				local function saveLayer(layer)
					layer.savedWeights:setToM(layer.weights)
					layer.savedBias:setToVA(layer.bias)
				end
				local function retrieveLayer(layer)
					layer.weights:setToM(layer.savedWeights)
					layer.bias:setToVA(layer.savedBias)
				end
				local function layerIterator()
					return ipairsL(nada),self.layers,1
				end

				if not self.initialized then
					self.initialized=true
					local initialize=true
					local previous_nodes=self.layers[1].nodes
					for i,layer in layerIterator() do
						local previous_nodes_count=#previous_nodes
						for j,row in ipairsL(layer.weights) do
							for k=1,previous_nodes_count do
								--ensure all weights are present even if they were pruned on laod
								row[k]=row[k] or 0
							end
						end
						previous_nodes=layer.nodes

						--ensure there was no previous training
						initialize=initialize and layer.bias:magnitudeVA()==0
					end
					if initialize then
						--if there was no previous training, apply some noise before we start
						for i,layer in layerIterator() do
							applyRandomness(layer,1)
						end
					end
					for i,layer in layerIterator() do
						layer.savedWeights=layer.weights:copyQM()
						layer.savedBias=layer.bias:copyVA()
						layer.weightDeltas=layer.weights:copyQM()
						layer.biasDeltas=layer.bias:copyVA()
					end
					self.agressiveness=rand()
					self.savedErrors=self:score(data)
				end

				local agressiveness=self.agressiveness
				local savedErrors=self.savedErrors
				for i=#self.layers,2,-1 do
					local layer=self.layers[i]
					local bool
					repeat
						applyRandomness(layer,agressiveness)--normalization)
						local newErrors=self:score(data)
						if newErrors<savedErrors then
							savedErrors=newErrors
							agressiveness=agressiveness*(1+rand())
							bool=true
							saveDeltas(layer)
							saveLayer(layer)
							for j=1,max_repeats do
								tryRepeatChange(layer,1+j/100)
								newErrors=self:score(data)
								if newErrors<savedErrors then
									savedErrors=newErrors
									saveLayer(layer)
								else
									retrieveLayer(layer)
									break
								end
							end
						else
							agressiveness=agressiveness*rand()
							retrieveLayer(layer)
						end
					until bool or agressiveness<1e-30
				end
				self.agressiveness=agressiveness>1e-15 and agressiveness or rand()
				self.savedErrors=savedErrors
				return savedErrors
			end,
			brokentrain=function(self,data,learning_rate,random_strength,normalization_strength,rand_seed)

				local function layerIterator()
					return ipairs(nada),self.layers,1
				end
				local function run(input)
					for i=1,#self.input do
						self.input[i]=input[i] or 0
					end

					for i,layer in layerIterator() do
						layer.pre_bias=layer.previous.nodes:matMultVA(layer.weights,	layer.pre_bias)
						layer.pre_activation=layer.pre_bias:addVA(layer.bias,			layer.pre_activation)
						layer.pre_activation:activateVA(layer.activation,				layer.nodes)
					end
					return self.output
				end
				local function init_batches()
					for i, layer in layerIterator() do
						--make sure is initialized
						layer.bias_deltas=layer.bias_deltas or sacVec.newVA(#layer.nodes)
						for i=1,#layer.bias_deltas do
							--make sure all is 0
							layer.bias_deltas[i]=0
						end

						--make sure is initialized
						layer.weight_deltas=layer.weight_deltas or Nuclea.Matrices.newVM(#layer.previous.nodes,#layer.nodes)
						for i,row in ipairs(layer.weight_deltas) do
							for col=1,#layer.previous.nodes do
								--make sure all is 0
								row[col]=0
							end
						end
					end
				end
				local function sum_batches(amount)
					for i, layer in layerIterator() do
						layer.bias:addMultVA(layer.bias_deltas,1/amount,layer.bias)
						layer.weights:addM(layer.weight_deltas,1/amount,layer.weights)
					end
					init_batches()
				end
				local function reverseInput(output,weights)
					local u,e,v=weights:svdM(1000)
					u=u:transposeM()
					e=e:transposeM()
					v=v:transposeM()
					for i=1,math.min(#e,#e[1]) do
						e[i][i]=1/e[i][i]
					end
					local inv=v:multiplyM(e):multiplyM(u)
					return output:matMultVA(inv)
				end
				local function applyRandomness(amount)
					local int='0xFFFF'~0
					--so I'm writing this because I saw this and didn't know wtf I did
					--basically, it's 4x4 bits, or, 2^16-1, except as int so no coversions
					--I did this as 0x because it was faster than taking out a calculator
					--then ~0 to just convert to int
					--lazy and fast in execution down below
					--now I write comment
					--silly me
					--I want it to stay as that as my legacy
					local xorshift=KineticaL.Nuclea.xorShift
					local a,b=2*amount,-amount
					local function rand()
						rand_seed=xorshift(rand_seed)
						return (((rand_seed>>4)&int)/int)*a+b
					end
					for i,layer in layerIterator() do
						for j,matrow in ipairs(layer.weights) do
							for k,weight in ipairs(matrow) do--column=1,#layer.previous.nodes do
								matrow[k]=weight+rand()
							end
						end
						local vec=layer.bias
						for j=1,#vec do
							vec[j]=vec[j]+rand()
						end
					end
				end
				local function applyNormalization(amount)
					for i,layer in layerIterator() do
						for j,matrow in ipairs(layer.weights) do
							for k,weight in ipairs(matrow) do--column=1,#layer.previous.nodes do
								matrow[k]=weight>amount and -amount or weight<amount and amount or -weight
							end
						end
						local bias=layer.bias
						for j,weight in ipairs(bias) do
							bias[j]=weight>amount and -amount or weight<amount and amount or -weight
						end
					end
				end

				learning_rate=learning_rate or 0.0001
				random_strength=random_strength or 0.2
				normalization_strength=normalization_strength or 0.3
				rand_seed=rand_seed or 1

				do	--initialization
					local previous_layer
					for i,layer in ipairs(self.layers) do
						layer.previous=previous_layer;
						--(previous_layer or {}).next=layer
						previous_layer=layer
					end
					local initialize=true
					for i,layer in layerIterator() do
						local previous_nodes=layer.previous.nodes
						local previous_nodes_count=#previous_nodes
						for j,row in ipairs(layer.weights) do
							for k=1,previous_nodes_count do
								--ensure all weights are present even if they were pruned on laod
								row[k]=row[k] or 0
							end
						end

						--ensure there was no previous training
						initialize=initialize and layer.bias:magnitudeVA()==0
					end
					if initialize then
						--if there was no previous training, apply some noise before we start
						applyRandomness(learning_rate)
					end
				end

				local function trainLayer(layer,ideal_output,weight)
					local l_rate,ideal_raw,input,pre_act_output,perf_weight,delta,perf_bias,new_weight
					l_rate=weight*learning_rate/#layer.previous.nodes

					ideal_raw=ideal_output:reverse_activateVA(layer.activation)
					input=layer.previous.nodes
					pre_act_output=layer.pre_activation

					for row_n,row_t in ipairs(layer.weight_deltas) do
						for col,v in ipairs(row_t) do
							perf_weight=ideal_raw[row_n]/input[col]
							perf_weight=perf_weight==perf_weight and perf_weight or 0
							delta=perf_weight-row_t[col]
							delta=perf_weight^2==1/0 and 0 or delta--when infinity, input was 0, don't change shit
							new_weight=row_t[col]+l_rate*delta
							new_weight=new_weight==new_weight and new_weight or row_t[col]
							row_t[col]=new_weight
							--row_t[col]=row_t[col]+l_rate*clamp(-1,1,delta) --alternative
						end
					end

					local bias_deltas=layer.bias_deltas
					for i=1,#bias_deltas do
						perf_bias=ideal_raw[i]-pre_act_output[i]
						delta=perf_bias-bias_deltas[i]
						new_weight=bias_deltas[i]+l_rate*delta
						new_weight=new_weight==new_weight and new_weight or bias_deltas[i]
						bias_deltas[i]=new_weight
						--bias_deltas[i]=bias_deltas[i]+l_rate*clamp(-1,1,delta) --alternative
					end

					--figure out ideal output for next iteration (previous layer)
					ideal_output=reverseInput(ideal_raw,layer.weights)
					return ideal_output
				end

				local function train_on_data(input,output,weight)
					run(input)
					local ideal_output=output
					local layers=self.layers
					for i=#layers,2,-1 do
						ideal_output=trainLayer(layers[i],ideal_output,weight)
					end
				end

				--used to ensure that this is a vector with proper methods
				--input is safely copied over inside of run() so it's fine
				init_batches()
				local temporary_output=Nuclea.Vectors.newV()
				for ib,batch in ipairs(data) do
					local weights=0
					for id, data in ipairs(batch) do
						local data_weight=data.weight or 1
						weights=weights+data_weight

						if #data.output~=#self.output then
							local throw_a_tantrum
							print('data '..id..', in batch '..ib.." size is not compatible with the AI model's output size.")
							throw_a_tantrum()
						end
						temporary_output:setToV(data.output)
						train_on_data(data.input,temporary_output,data_weight)
					end
					--add the appropriate weighted sum
					sum_batches(weights)
					--applying randomness per each iteration would be pointless as it'd average towards 0
					applyRandomness(weights*learning_rate*random_strength)
					--applying normalization towards 0 would be stupid as it'd keep on stacking, overpowering the learning
					applyNormalization(weights*learning_rate*normalization_strength)
				end
			end
		}
	end

}
---@endsection SYNAPTICACLASS
