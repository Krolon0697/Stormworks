
---@section K_Script 1 ASMCLASS
Krolony.K_Script={

    ---@section creator_K_Script
    creator_K_Script=function()
        local customDraws,offsets,cus_func={},{['Ci']=2,['Li']=4,['Re']=4,['Tr']=6,['Te']=3}
        for key,v in pairs(screen) do
            cus_func=(key:find('draw') and key:sub(5) or key:sub(4)):lower()
            cus_func=#cus_func>6 and cus_func:gsub("(.).", "%1") or cus_func --somehow deletes every 2nd char thanks to gpt god
            customDraws[cus_func]=function(offx,offy,w,h,...)
                local inputs,identification,offxy,bool={...},key:sub(5,6)
                for j=1,offsets[identification] or 0 do
                    bool=j%2==1
                    offxy=bool and offx or offy
                    
                    inputs[j]=
                        identification=='Te' and j==3 and tostring(inputs[3]):sub(1,(2+offx+w-inputs[1])//5) or
                        identification=='Re' and j>2 and math.min(inputs[j],offxy+(bool and w or h)-inputs[j-2]) or
                        Krolony.Utilities.clamp(0,bool and w or h - (identification=='Te' and 5 or 0),inputs[j])+offxy
                end
                return v(table.unpack(inputs)) and (key:sub(4,4)=='W' and w or h)
            end
        end

        local decodeWord=function(bits,_word_)
            _word_=''
            for i=0,5 do
                _word_=_word_..string.char(94+((bits&(31<<(5*i)))>>(5*i)))
            end
            return _word_:sub(1,(_word_:find('}') or 7)-1):gsub('{',' '):gsub('|',':')
        end
        return {
            codes={},

            ---@section install
            ---takes machinecode and puts it in a global table in usable form
            ---@param machinecode table
            install=function(self,machinecode)
                local codes,name,i,line,code,com,v,lim=self.codes,decodeWord(machinecode[1])..decodeWord(machinecode[2]),4,0
                codes[name]={mode=machinecode[3]>>26,lines={},registers={},dictionary={}} --prepare for usage

                code=codes[name].lines
                lim=(machinecode[3]>>10)&65535
                while i<lim do
                    line=line+1
                    com=machinecode[i]
                    code[line]={[0]=com}
                    for j=1,1+((com>>24)&7) do
                        i=i+1
                        v=machinecode[i]
                        code[line][j]=(com&2^27~=0 and j==1 or com&2^28~=0 and j>2) and v or (v>>1)*(1-2*(v&1))--(v&(2^29-1))*(v&2^29~=0 and -1 or 1)
                    end
                    i=i+1
                end--installs actual app
                --[[]]
                while i<lim+2*(machinecode[3]&1023) do
                    codes[name].dictionary[decodeWord(machinecode[i])]=machinecode[i+1]
                    i=i+2
                end--[[]]--adds the dictionary - register addresses for text-compatible variable names
            end,
            ---@endsection
            
            ---@section parse
            ---@param name string 6 letters indicating the name of the code to run (if installed)
            ---@param x number x pos of the window
            ---@param y number y pos of the window
            ---@param w number width of the window
            ---@param h number height of the window
            parse=function(self,name,args,x,y,w,h,custom_registers)
                local code,jumpbacks,stack,lines,registers,instructions,command,out,i,line,getText,read,pack_args,ret,send_args,write,cast,safety,CBE=self.codes[name],{},{}
                --local code,lines,registers,args,instructions,command,out,global_regs,_v1_,_v2_,i,line,loc,access_reg,getText
                if not code then return end
                if not x then x,y,w,h=0,0,999,999 end
                getText=function(start,_txt_)
                    _txt_=''
                    for i=start,#line do
                        _txt_=_txt_..decodeWord(line[i])
                    end
                    return _txt_
                end
                safety=function(x)
                    return (x~=x or x==1/0 or x==-1/0) and 0 or x
                end
                read=function(pos,_v1_,_v2_,_vtype_)
                    _v1_,_vtype_=line[pos] or 0,(command&(192<<(pos*2)))>>(pos*2+6)
                    --if $ then take number else access register
                    _v2_=_vtype_==2 and _v1_ or registers[_v1_] or 0
                    --if * then read from that reg
                    _v2_=_vtype_~=1 and _v2_ or registers[_v2_] or 0
                    --type check
                    --0 no cast, 64 cast bool, 128 cast int
                    return cast==0 and _v2_ or cast==64 and (_v2_~=0 and 1 or 0) or safety(_v2_-_v2_%(_v2_/math.abs(_v2_)))--_v2_-(math.abs(_v2_)%1)*(_v2_<0 and -1 or 1)
                end
                write=function(pos,val)
                    pos=command&(64<<(2*pos))~=0 and registers[line[pos]] or line[pos]
                    registers[pos]=safety(val) or registers[pos]
                end
                pack_args=function(start,_args_)
                    _args_={}
                    for i=start,#line do
                        _args_[i-start+1]=read(i)
                    end
                    return _args_
                end--
                --[[CBE=function(a,b,metadata,_out,_meta,_a,_b)--conditional bitwise evaluator
                    repeat
                        _meta=metadata&511
                        _a=_meta>>7==1 and _out or a
                        _b=_meta>>8==1 and _out or b
                        _meta=_meta&127
                        _out=((_meta&1==1 and _a>_b or _meta&2==2 and _a==_b) and 1 or 0) + --conditionals
                            (_meta>>2)*(_a&_b) + --and bit and bool
                            (_meta>>3)*(_a|_b) + --or bit and bool
                            (_meta>>4)*(_a<<_b) + --shift
                            (_meta>>5)*(~_a) + --int not
                            (_meta>>6)*(1-_a) --bool not
                        metadata=metadata>>9
                    until metadata==0
                    return _out
                end
                CBE()]]
                instructions={
                    function() out=read(2)+(line[3] and read(3)*(line[4] and safety(read(4)/read(5)) or 1) or 0) end, --arthm a = b + c * d / e
                    --acts as set, mult, div, add, everything
                    function() out=read(2)^safety(read(3)/read(4)) end, --power
                    function() out=read(2)<<read(3) end, --int shift left
                    function() out=~read(2) end, --int not
                    function() out=read(2)|read(3) end, --int or
                    function() out=read(2)&read(3) end, --int and
                    function() out=read(2)==read(3) and 1 or 0 end, --comp equal
                    function() out=read(2)>read(3) and 1 or 0 end, --comp greater
                    function() out=input.getNumber(read(2)) end, --input number
                    function() out=input.getBool(read(2)) and 1 or 0 end, --input bool
                    function() out=property.getNumber(getText(3)) or 0 end, --property number
                    function() output.setNumber(read(1),read(2)) end, --output number
                    function() output.setBool(read(1),read(2)~=0) end, --output bool
                    function() customDraws['text'](x,y,w,h,read(1),read(2),getText(3)) end, --screen text
                    function()
                        if read(2)~=0 then
                            --if cast==128 then table.insert(jumpbacks,i) end
                            --table.insert(jumpbacks,cast~=0 and i or nil)
                            jumpbacks[#jumpbacks+1]=cast~=0 and i or nil
                            i=read(1)+read(3)//1
                        end
                    end, --conditional jump - line condition
                    function()
                        args=self:parse(getText(3),send_args,x,y,w,h)
                    end, --call other code
                    function() out=read(2)~=0 and read(3) or read(4) end, --ternary outreg condition fortrue forfalse
                    function(func)
                        func=math[decodeWord(line[1])]
                        out=math.type(func) and func or func(table.unpack(pack_args(3)))
                    end, --math lib
                    function()
                        out=customDraws[decodeWord(line[1])](x,y,w,h,table.unpack(pack_args(2)))
                    end, --screen lib
                    function()
                        ret=pack_args(1)
                        i=1/0
                    end, --return
                    function()
                        send_args=pack_args(1)--#pack_args(1)>0 and pack_args(1)
                    end, --pack args 
                    function()
                        for fiut=1,#line do
                            write(fiut,(args or {})[fiut])
                        end
                    end, --get args
                    function()
                        i=jumpbacks[#jumpbacks] or i
                        table.remove(jumpbacks,#jumpbacks)
                    end, --jumpback
                    function()
                        for arg=1,#line do
                            --table.insert(stack,read(arg))
                            stack[#stack+1]=read(arg)
                        end
                    end,--push
                    function()
                        for arg=1,#line do
                            write(arg,stack[#stack])
                            table.remove(stack,#stack)
                        end
                    end,--pop
                    function(v)
                        if read(3)~=0 then
                            v=read(1)
                            write(1,read(2))
                            write(2,v)
                        end
                    end--swap
                    ,function() print(table.unpack(pack_args(1))) end --print
                }
                lines=code.lines
                registers=custom_registers or code.registers

                i=1
                while i<=#lines do
                    line=lines[i]
                    command=line[0]
                    cast=command&192
                    out=nil
                    instructions[command&63]()
                    write(1+(command>>29),out)

                    i=i+1
                end
                return ret
            end,
            ---@endsection
        }
    end,
    ---@endsection

    ---@section compile
    ---comment
    ---@param snippet string can be a longstring, is the instructions
    ---@param name string up to 12 chars, indicating a name
    ---@param mode integer 0 for utility tools that only get called, 1 for drivers that always run but never display things, 2 for normal window apps
    ---@param export_dictionary bool well it speaks for itself, true to include dictionary for self:read/writeReg()
    ---@return table machinecode serialized series of numbers in a 1d table
    compile=function(snippet,name,mode,export_dictionary)
        --[[
            to do
            built in nor xor xnor nand clamp lerpx lerpt
            make more compact... yea that went fucking well
        ]]
        local commands={
            --[[
            name has to be 12 chars or less
            you can only use "^_`abcdefghijklmnopqrstuvwxyz :" in name and in script as text
            in parsing language is case-sensitive, var myVar is different than myvar
            but when you call stuff (other k-scripts or math/screen funcs) it's all lowercase so becomes case-insensitive
            you can only type in integers, but once running floats are being used (that's why some commands have x/y)
            booleans are 1 and 0, but truth is evaluated as bool~=0 so any number other than 0 is true
            encoding is 30bit, so you can only use numbers from -536870911 to 536870911
            every command can begin with an "i" or "b" to cast arguments into int or bool
            int cast is truncating so both 0.9 and -0.9 become 0
            bool cast casts every number to 1, while 0 stays as 0
            bitwise commands are forced to be cast
            only arguments are being cast, so iarthm => float a = int b + int c * float( int d / int e )
            empty registers are evaluated as 0 so no nils
            if you try to set a to value of empty reg it becomes 0, cuz empty regs are 0
            if you try to set a to nil (more args given to getargs than receiving) then a=a
            if a = +-inf or nan then a=0
            arthm a b $c *d evaluates as register a, register b, number c, value at register to whuch adress is stored at d (d is pointer)
            arthm *a saves the result to register with adress stored at a  (a is pointer)
            jumpback and stack are created at the start of a parse and deleted at the end, these do not persist across calls
            jumpback acts as a stack too, if no values at jumpback stack then don't jump...back
            registers persist across calls, each script has a set of own registers unless custom_registers is given, then this is the reg table
            ]]
            'arthm',	-- a = b + c * d / e	(c d e are optional), acts as set add sub mult div all at once
            'pwr',		-- a = b ^ (c / e)		(e is optional)
            'shftl',	-- a = b << c
            'not',		-- a = ~ b --this is int not!!! won't work as bool not! 1 becomes -2 and 0 becomes -1
            'or',		-- a = b | c --int or!
            'and',		-- a = b & c --int and!
            --for booleans you have to craft arthm commands if int or/and won't do
            'eql',		-- a = b == c
            'grt',		-- a = b > c
            'jnn',		-- a = input.getNumber( b ) --in number... except j because i is intcast
            'jnb',		-- a = input.getBool( b )
            'prp',		-- a = property.getNumber( text )
            'outn',		-- output.setNumber(a , b)
            'outb',		-- output.setBool(a , b)
            'dtxt',		-- drawText( a , b , text), for drawing the content of register use screen text
            'jump',		-- if b then jump to LABEL a, b is optional, if not present then just jump, use *jump to allow for jumpback
            --third optional argument is offset, +1 +2 -1 -2 whatever you want, only use if you know what you're doing
            --basically allows for case/switch operation
            'call',		-- calls other K_Script with packed args with name up to 12 chars
            'trn',		-- a = if b then c else d
            'math',		-- a = b( c d e f g h )
            -- b is math function, only 6 values can be used
            'screen',	-- if width/height then a = b() else a( b c d e f g h )
            -- b is screen function, max 6 chars, that would eliminate circleF, triangle and triangleF
            --so for these 2nd 4th and 6th chars are ereased, so - screen crlf is circleF, tinl is triangle and tinlf is triangleF
            --"set" "get" and "draw" are deleted from the function names so don't worry about these
            'return',	-- return packed args
            'packargs',	-- packs a b c d e f g h to be sent on next call command
            'getargs',	-- a b c d e f g h = received args or remains same when not enough args are given
            'jumpback',	-- goes back to last position from which it jumped from (stacks)
            'push', --pushes arg a then pushes arg b then pushes arg c...
            'pop', --pops into reg/pointer a then pops into r/p b then pops into r/p c...
            'swap',--swaps a and b if c
            'print',	-- print ( a b c d e f g h ) don't use in SW obv
            find=function(self,txt)
                for i,v in ipairs(self) do
                    if txt==v then return i end
                end
            end
        }
        local error=function(message,tab)
            print(message)
            if tab then print(tab[0],table.unpack(tab)) end
        end
        local codeName=function(str,line)
            local v=0
            str=str or ''
            if #str>6 then
                error('name too long, max 12 chars, 6 in code',line)
            end
            str=str:sub(1,6)
            str=str:lower()--get name, 6 chars
            str=str:gsub(' ','{'):gsub(':','|')
            for i=1,6 do
                if #(str:sub(i,i))==0 then
                    v=v+(31<<(5*i-5))
                    break
                end
                if not ([[^_`abcdefghijklmnopqrstuvwxyz{|]]):find(str:sub(i,i),nil,true) then
                    return error('incorrect name, use chars from 95 to 126',line)
                end

                v=v+(((str:sub(i,i):byte()-94)&31)<<(5*i-5))
            end
            return v
        end

        local account_for_cast=function(command,key)
            return command==key or (command:sub(1,1)=='i' or command:sub(1,1)=='b') and command:sub(2)==key
        end

        local code,i,substring,out,dictionary,taken,word,com,v,lastfree,props,jumps,j,discarded
        code={}
        jumps={}
        discarded={}
        i=1
        snippet=snippet:gsub(';','')
        repeat --cut snippet into lines, cut lines into args
            substring=snippet:sub(1,snippet:find('\n',1,true)-1)
            while #substring==0 or not substring:find('%g+') do
                snippet=snippet:sub(snippet:find('\n',1,true)+1)
                substring=snippet:sub(1,snippet:find('\n',1,true)-1)
            end
            j=0
            code[i]={}
            for v in substring:gmatch('%g+') do
                code[i][j]=v
                --prepare prp and call to use same encoding as dtxt
                if (account_for_cast(code[i][0],'prp') or account_for_cast(code[i][0],'call')) and j==0 then
                    code[i][1]='$0'
                    code[i][2]='$0'
                    j=2
                end
                j=j+1
            end
            --pad to make sure arguments are present
            if account_for_cast(code[i][0],'jumpback') or account_for_cast(code[i][0],'return') and not code[i][1] then code[i][1]='$0' end
            --default 1s to commands when arguments not explicitly present
            if account_for_cast(code[i][0],'pwr') and not code[i][4] then code[i][4]='$1' end
            if account_for_cast(code[i][0],'arthm') and code[i][4] and not code[i][5] then code[i][5]='$1' end
            if account_for_cast(code[i][0],'swap') and not code[i][3] then code[i][3]='$1' end
            if code[i][0]=='shiftl' or code[i][0]=='not' or code[i][0]=='or' or code[i][0]=='and' then
                error('no cast detected, forcing int cast',code[i])
                code[i][0]='i'..code[i][0]
            end
            --make sure arguments are present, except comments
            if #code[i]==0 and code[i][0]:sub(1,1)~='/'then
                return error('no arguments given',code[i])
            end
            --save labels for jumps
            if code[i][0]=='label' then
                for label,jumpto in pairs(jumps) do
                    if code[i][1]==label then
                        return error("label already exists elsewhere",code[i])
                    end
                end
                jumps[code[i][1]]=i
            end
            j=3
            --encode text in call, dtxt and prp commands
            if account_for_cast(code[i][0],'call') or account_for_cast(code[i][0],'dtxt') or account_for_cast(code[i][0],'prp') then
                substring=''
                for arg=j,#code[i] do
                    substring=substring..code[i][arg]..' '
                end
                substring=substring:sub(1,#substring-1)
                --ensure name length limit
                if account_for_cast(code[i][0],'call') and #substring>12 then return error('names can only be up to 12char long',code[i]) end
                for pos=1,#substring,6 do
                    code[i][j]='$'..tostring(codeName(substring:sub(pos,pos+5),code[i]))
                    j=j+1
                end
                --once done encoding remove excess remaining table data
                for pos=j,#code[i] do
                    code[i][pos]=nil
                end
            end
            --encode screen math function names
            if account_for_cast(code[i][0],'screen') or account_for_cast(code[i][0],'math') then
                code[i][1]='$'..tostring(codeName(code[i][1],code[i]))
            end
            local first_letter,second_letter=code[i][0]:sub(1,1),code[i][0]:sub(2,2)
            --delete non commands
            if code[i][0]~='*jump' and --except jumps meant to jumpback
                not commands:find(code[i][0]) and --unfound command
                not ((first_letter=='i' or first_letter=='b') and --tbh I can't comment it
                not (second_letter=='i' or second_letter=='b') and
                commands:find(code[i][0]:sub(2))) then
                --if not command found and not (cast command found) but not double cast
                --deletes labels, comments, bad commands, but iadd or badd can go through as it's add with int/bool cast
                --block double cast
                --don't print out labels and comments
                if code[i][0]~='label' and code[i][0]:sub(1,1)~='/' then
                    table.insert(discarded,code[i])
                end
                --delet
                code[i]=nil
                i=i-1
            end
            snippet=snippet:sub(snippet:find('\n',1,true)+1)
            i=i+1
        until #snippet==0 or not snippet:find('\n',1,true) or not snippet:find('%g+')

        --find jumps to the labels
        for i,line in ipairs(code) do
            if line[0]=='jump' or line[0]=='*jump' then
                line[0]=line[0]=='jump' and line[0] or 'ijump' --reuse int cast flag as jumpback stack insert
                local found=false
                for label,jumpto in pairs(jumps) do
                    if line[1]==label then
                        found=true
                        code[i][1]='$'..tostring(jumpto-1)
                    end
                end
                --default condition to 1 if not present
                line[2]=line[2] or '$1'
                --default offset to 0
                line[3]=line[3] or '$0'
                if not found then return error ("didn't find label",line) end
            end
        end

        --output table
        out={codeName(name:sub(1,6)),codeName(name:sub(7,12)),0}
        --table with register indexes for viable var names
        dictionary={}
        --mark registers which are sure not free for var names
        taken={}
        word=3
        for j,line in ipairs(code) do
            word=word+1
            com=word
            --make sure casts are acknowledged
            out[com]=commands:find(line[0]) or commands:find(line[0]:sub(2))
            out[com]=out[com]+(math.min(7,#line-1)<<24)+(line[0]:sub(1,1)=='i' and 128 or line[0]:sub(1,1)=='b' and 64 or 0)
            --command + len + normn + normb at their correct places
            --1     1    1    3   16                        1   1         6
            --1     0    1    000 11 11 11 11 11 11 11 11   0   1         000000
            --shift dtxt func len  number reg pointer       int/bool cast command
            --func = math or screen function
            local is_func=account_for_cast(line[0],'math') or account_for_cast(line[0],'screen')
            local is_dtxt=account_for_cast(line[0],'call') or account_for_cast(line[0],'dtxt') or account_for_cast(line[0],'prp')
            local shift_output=account_for_cast(line[0],'math') or account_for_cast(line[0],'screen')
            out[com]=out[com]+(is_func and 134217728 or 0)
            out[com]=out[com]+(is_dtxt and 134217728*2 or 0)
            out[com]=out[com]+(shift_output and 134217728*4 or 0)
            for k,arg in ipairs(line) do
                if #line>8 then error('too many arguments given to line, pruning',line) end
                if k<9 then --max 8 args
                    word=word+1
                    if arg:sub(1,1)=='*' then
                        code[j][k]=arg:sub(2)--get rid of *
                        out[com]=out[com]+(64<<(2*k)) --indicate a pointer
                    end
                    if arg:sub(1,1)=='$' then
                        code[j][k]=arg:sub(2)--get rid of *
                        out[com]=out[com]+(128<<(2*k)) --indicate a number
                    end

                    v=tonumber(code[j][k])
                    if v then --if number then
                        if v%1~=0 then error('float number, converting to int',line) end
                        v=(v+0.5)//1 --make sure is int, round (during parsing it's truncating)
                        if math.abs(v)>536870911 and not (is_func and k==1 or is_dtxt and k>2) then
                            return error('number too large',line)
                        end
                        v=((is_func and k==1 or is_dtxt and k>2 or is_func and is_dtxt) and v) or (math.abs(v)<<1)+(v>=0 and 0 or 1)--(math.abs(v)&536870911)+(v>=0 and 0 or 536870912)
                        --29 bit int, 30th bit is sign
                        --but don't do on first arg if is_func or 3-8 if it's encoded text
                        out[word]=v --save conversion
                        taken[v]=true --make sure words don't take same registers as numbers
                    end
                end
            end
            --indicates a number flag for unspecified arguments
            --why... idk... must have been needed at some point...
            --I'm too scared not to do it now...
            for k=#line+1,8 do
                out[com]=out[com]+(128<<(2*k))
            end
            if word>65530 then return error('god damn too much code') end
        end
        word=3
        lastfree=0
        for j,line in ipairs(code) do
            --do a second time to make sure words NEVER take same registers as specified numbers/explicitly specified regs, search
            word=word+1
            for k,arg in ipairs(line) do
                if k<9 then
                    word=word+1
                    v=tonumber(arg)
                    if not v then --if not number but word then
                        if dictionary[arg] then
                            v=dictionary[arg] --if we seen that word then take from saved things
                        else
                            for i=lastfree-1,-lastfree-2^16,-1 do --search for free spots
                                if not taken[i] then --if free
                                    local reg=(math.abs(i)<<1)+1--convert to neg
                                    lastfree=i --save to continue search from same (+1) location
                                    dictionary[arg]=reg --save that word to not search again later
                                    taken[reg]=true --mark as taken register
                                    v=reg --finally assign word to a register value
                                    break
                                end
                            end
                        end
                        out[word]=v
                    end
                    --now even words are numbers, registers!
                    --kinda funny because can be used as a $number :skull:
                    --that can be predicted sure but is weird af and usually unknown
                    --yet can be multiplied and added and all the shit
                    --maybe fine for pointer shenanigans?
                end
            end
        end
        mode=mode or 0
        props=(mode&15)<<16--get properties, 4 bits for metadata...?, 16 for length, 10 for dictionary length
        --kinda arbitrarily chosen tbh, but if someone manages to write between 8 and 32k commands required to hit the limit...
        --really I have no words then
        props=props+#out
        props=props<<10
        if export_dictionary then--default off to have smaller app install size, if someone needs it for their own project then by all means
            for var,value in pairs(dictionary) do
                local isgood=true
                for i=1,6 do
                    isgood=isgood and ([[^_`abcdefghijklmnopqrstuvwxyz: ]]):find(var:sub(i,i),nil,true)
                end
                if #var<7 and isgood then
                    out[word+1]=codeName(var)
                    out[word+2]=value
                    word=word+2
                end
            end
        end
        local dictionary_size=(#out-((props>>10)&65535))/2
        if dictionary_size>1023 and export_dictionary then return error('too many variables') end
        out[3]=props+dictionary_size
        if #discarded>0 then
            print('discarded lines:')
            for i,v in ipairs(discarded) do
                local txt=''
                for j=0,#v do
                    txt=txt..' '..v[j]
                end
                print(txt)
            end
        end
        return out
    end,
    ---@endsection

    ---@section compress
    ---@param code table machinecode to compress
    ---@return string compressed data
    compress=function(code)
        local txt,memory,max_lookback='',{},58
        for i=1,max_lookback+1 do
            memory[i]=0/0
        end
        local function encode(v)
            local out,origv='',v
            local mask,not_mask
            --encode v into chars
            for i=0,5 do
                mask=v&(31<<(i*5))
                not_mask=~mask
                out=out..string.char(33+((v&mask)>>(i*5)))
                v=v&not_mask
                if v==0 then
                    table.insert(memory,origv)
                    break
                end
            end
            for i=max_lookback,1,-1 do
                if memory[i]==origv then
                    local bleh=max_lookback-i+1
                    bleh=33+32+bleh
                    if bleh>95 then bleh=bleh+1 end
                    return string.char(bleh)
                end
            end
            return out..string.char(33+32)
        end
        for i,v in ipairs(code or {}) do
            txt=txt..encode(v)
            while #memory>max_lookback do
                table.remove(memory,1)
            end
        end
        txt=txt:gsub("'",'~'):gsub(string.char(92),'}')
        return txt
    end,
    ---@endsection

    ---@section built_in 1 BUILT_INCLASS
    built_in={
        --xnor nand clamp lerpx lerpt >= ~= pid? rolling_average?
        ---@section sources 1 SOURCECLASS
        sources={
            inputs_K_Script=[[
                getargs tick touchx touchy touch
                    jump onTick tick
                label ondraw
                    screen color $255 $255 $255
                    arthm not_touch $1 $-1 touch
                    jump not_touched not_touch
                    arthm touchx touchx $-1
                    arthm touchy touchy $-1
                    screen rect touchx touchy $2 $2
                label not_touched
                    dtxt $50 $0 touch
                    dtxt $50 $10 ws
                    dtxt $50 $20 ad
                    dtxt $50 $30 ud
                    dtxt $50 $40 lr
                    dtxt $0 $0 bool a
                    dtxt $0 $10 bool b
                    dtxt $0 $20 bool c
                    dtxt $0 $30 bool d
                    dtxt $0 $40 bool e
                    dtxt $0 $50 bool f
                    screen text $80 $0 touch
                    screen text $80 $10 ws
                    screen text $80 $20 ad
                    screen text $80 $30 ud
                    screen text $80 $40 lr
                    screen text $40 $0 b1
                    screen text $40 $10 b2
                    screen text $40 $20 b3
                    screen text $40 $30 b4
                    screen text $40 $40 b5
                    screen text $40 $50 b6
                    return
                label onTick
                    jnn ws $23
                    jnn ad $24
                    jnn ud $25
                    jnn lr $26
                    jnb b1 $21
                    jnb b2 $22
                    jnb b3 $23
                    jnb b4 $24
                    jnb b5 $25
                    jnb b6 $26
                    arthm ws $0 ws $10000
                    iarthm ws $0 ws $1 $10000
                    arthm ad $0 ad $10000
                    iarthm ad $0 ad $1 $10000
                    arthm ud $0 ud $10000
                    iarthm ud $0 ud $1 $10000
                    arthm lr $0 lr $10000
                    iarthm lr $0 lr $1 $10000
            ]],
            ecu_K_Script=[[
                getargs tick
                jump tick tick

                label high_temp_color
                    screen color $255 $0 $0
                jumpback

                label draw
                    arthm flash $0 ticks $1 $20
                    iand flash flash $1
                    grt high_temp $1 temp_limit
                    iand flash flash high_temp

                    screen color $100 $100 $100
                    dtxt $0 $0 ratio
                    dtxt $0 $10 afrtg
                    dtxt $0 $20 afrfb
                    dtxt $0 $40 rps
                    screen text $30 $0 ratio
                    screen text $30 $10 targetafr
                    screen text $30 $20 afr_fb
                    iscreen text $30 $40 rps
                    jump high_temp flash
                    *jump high_temp_color high_temp
                    dtxt $0 $30 temp
                    iscreen text $30 $30 temperature

                label high_temp
                return

                label tick
                    arthm ticks ticks $1
                    jnn air $1
                    jnn fuel $2
                    jnn temperature $3
                    jnn rps $4
                    jnn ws $23
                    jnb turned_on $21
                    arthm throttle $0 ws $10 $9
                    arthm throttle throttle $-1 $1 $9
                    arthm brakes $0 $-1 ws $2
                    arthm brakes brakes $1 $1 $20
                /targetafr = (-0.2 * (3 * temp + 200) + temp + 1400)/100
                    arthm targetafr $200 3 temperature
                    arthm targetafr temperature targetafr $-2 $10
                    arthm targetafr targetafr $1400
                    arthm targetafr $0 targetafr $1 $100
                    arthm afr_fb $0 $1 air fuel

                    grt skip_ratio rps $55
                    eql temporary air $0
                    bor skip_ratio skip_ratio temporary
                    /jump skip_ratio skip_ratio

                    arthm ratio_temp $0 $1 targetafr afr_fb
                    pwr ratio_temp ratio_temp $1 $100
                    arthm ratio $0 ratio ratio_temp
                label skip_ratio
                    math min ratio ratio $3
                    math max ratio ratio $1
                    arthm idle $6 rps $-1
                    arthm idle $0 $1 idle $2
                    arthm temporary $0 $1 $1 $25
                    math max throttle throttle idle temporary
                    arthm throttle $0 throttle turned_on

                    grt bool rps $10
                    trn clutch_change bool $1 $-4
                    arthm clutch clutch clutch_change $1 $120
                    grt bool $6 rps
                    trn clutch bool $0 clutch
                    math max clutch clutch $0
                    math min clutch clutch $1

                    arthm temp_limit $110 $-1 temperature
                    arthm maxthrottle $0 $1 $1 ratio
                    math min throttle throttle maxthrottle temp_limit
                    outn $2 throttle
                    arthm throttle $0 throttle ratio
                    outn $1 throttle
                    outn $3 clutch
                    outn $4 brakes
                    grt starter $3 rps
                    band starter starter turned_on
                    outb $1 starter

            ]],
            pong_K_Script=[[
                getargs tick touchx touchy touch
                jump ontick tick;
                jump ondraw;

                label bounce;
                math random change;
                arthm ball_vx ball_vx ball_vx change $10
                math random change;
                /ball_vy = ball_vy + random(-0.1,0.1);
                arthm change $0 $1 change $5;
                arthm change change $1 $-1 $10;
                arthm ball_vy ball_vy change;
                jumpback;

                label reset;
                arthm alive $1;
                arthm dead_ticks $0;
                arthm enemy_x $5;
                arthm player_x width $5 $-1;
                arthm ball_x $8;
                arthm ball_y $5;
                math random angle;
                arthm angle angle $-1 $1 $2;
                math cos ball_vx angle;
                math sin ball_vy angle;
                arthm ball_vx $0 ball_vx $1 $2
                arthm ball_vy $0 ball_vy $1 $2
                jump end $1;

                label ontick;
                getargs tick touchx touchy touch
                jump alive alive;
                arthm dead_ticks dead_ticks $1;
                grt temp dead_ticks $10;
                jump reset temp;
                jump end $1;
                label alive;
                arthm player_y touchy;
                arthm enemy_y ball_y;
                arthm ball_x ball_x ball_vx;
                arthm ball_y ball_y ball_vy;

                /roof floor collision;
                grt temporary1 height ball_y;
                grt temporary2 ball_y $0;
                band temp temporary1 temporary2;
                jump skip_collision temp;
                arthm ball_vy $0 ball_vy $-1;
                label skip_collision;
                
                /player collision;
                ieql temp ball_x player_x;
                arthm temp $1 temp $-1
                jump skip_player_collision temp;
                /check height;
                arthm y1 player_y $5;
                arthm y2 player_y $-5;
                grt temporary1 ball_y y1;
                grt temporary2 y2 ball_y;
                bor temp temporary1 temporary2;
                jump end temp;
                arthm ball_vx $0 ball_vx $-1;
                arthm ball_x ball_x $-1;
                *jump bounce $1;
                jump end $1;

                label skip_player_collision;
                /enemy collision;
                ieql temp ball_x enemy_x;
                arthm temp $1 temp $-1
                jump skip_enemy_collision temp;
                arthm ball_vx $0 ball_vx $-1;
                arthm ball_x ball_x $1;
                *jump bounce $1;
                label skip_enemy_collision;

                /when ball out then dead;
                grt alive width ball_x;
                grt temp ball_x $0;
                band alive alive temp;
                jump end $1;

            label ondraw;
                screen color $0 $0 $20;
                screen rectf $-10 $-10 $300 $300;

                /print tick ws ad ud lr touchx touchy touch
                arthm bool touch $-1
                jump skip_test bool
                screen color $50 $50 $50
                arthm bleh touchx $1
                screen line touchx touchy bleh touchy
            label skip_test
                screen color $255 $255 $255;
                screen height height;
                screen width width;
                arthm x ball_x $1;
                screen line ball_x ball_y x ball_y;
                arthm y1 player_y $-5;
                arthm y2 player_y $5;
                screen line player_x y1 player_x y2;
                arthm y1 enemy_y $-5;
                arthm y2 enemy_y $5;
                screen line enemy_x y1 enemy_x y2;
                label end;
            ]],
            clamp_K_Script=[[
                    getargs v1 v2 v3
                    grt bool v1 v3
                    swap v1 v3 bool
                    grt bool v1 v2
                    trn v2 bool v1 v2
                    grt bool v2 v3
                    trn v2 bool v3 v2
                    return v2
            ]],
            lerpx_K_Script=[[
                getargs x x1 y1 x2 y2;
                arthm par1 x x1 $-1;
                arthm par2 y2 y1 $-1;
                arthm parl $0 par1 par2;
                arthm parr x2 x1 $-1;
                arthm result $0 $1 parl parr;
                arthm result result y1;
                return result
            ]],
            lerpt_K_Script=[[
                getargs t y1 y2;
                arthm result y2 y1 $-1;
                arthm result y1 result t;
                return result
            ]],
            draw_arc_K_Script=[[
                arthm arc $0 $1 $62831853 $10000000
                arthm offset $0
                arthm segments $10
                /default values
                getargs cx cy r segments arc offset

                /initialize
                arthm i $1
                arthm angle offset arc $0 segments
                math cos c angle
                math sin s angle
                arthm xl cx s r
                arthm yl cy c r $-1
                label loop
                    arthm angle offset arc i segments
                    math cos c angle
                    math sin s angle
                    arthm x cx s r
                    arthm y cy c r $-1
                    screen line x y xl yl
                    arthm xl x
                    arthm yl y
                    grt bool segments i
                    arthm i i $1
                    jump loop bool
            ]],
            in_rect_K_Script=[[
                getargs px py x y w h
                grt bool1 px x
                grt bool2 py y
                arthm w x w
                arthm h y h
                grt bool3 w px
                grt bool4 h py
                band bool5 bool1 bool2
                band bool6 bool3 bool4
                band bool bool5 bool6
            ]],
            conway_K_Script=[[
                arthm touch_last touch
                getargs tick touchx touchy touch
                jump tick tick
                    screen width screenw
                    screen height screenh
                    screen color $255 $255 $255
                    arthm x $0
                    arthm y $0
                    label loop_draw
                        arthm index x y screenw
                        *jump draw *index
                        arthm x x $1
                        eql bool x screenw
                        trn x bool $0 x
                        arthm y y $1 bool
                        grt bool screenh y
                        jump loop_draw bool
                return
                label draw
                    arthm x1 x $1
                    screen line x y x1 y
                jumpback

                label tick
                    jump touched touch
                    arthm x $0
                    arthm y $0
                    label loop_tick
                        arthm index x y screenw
                        arthm count $0
                        arthm alive *index
                        push x y index
                        
                            arthm x x $-1
                            arthm y y $-1
                            arthm index x y screenw
                            arthm count count *index
                            arthm index index $1
                            arthm count count *index
                            arthm index index $1
                            arthm count count *index
                            arthm index index $1
                            arthm y y $1
                            arthm index x y screenw
                            arthm count count *index
                            arthm index index $2
                            arthm count count *index
                            arthm y y $1
                            arthm index x y screenw
                            arthm count count *index
                            arthm index index $1
                            arthm count count *index
                            arthm index index $1
                            arthm count count *index
                            arthm index index $1

                        pop index y x
                        jump tick_alive alive
                            eql bool count $3
                            trn *index bool $1 *index
                            jump skip_alive
                        label tick_alive
                            grt bool1 count $3
                            grt bool2 $2 count
                            bor bool bool1 bool2
                            trn *index bool $0 *index
                        label skip_alive
                    arthm x x $1
                    eql bool x screenw
                    trn x bool $0 x
                    arthm y y $1 bool
                    grt bool screenh y
                    jump loop_tick bool
                return

                label touched
                    arthm index touchx touchy screenw
                    jump skip_touch touch_last
                    arthm state *index
                    arthm state $1 state $-1
                    label skip_touch
                        arthm index touchx touchy screenw
                        arthm *index state
                        
            ]],
            modulo_K_Script=[[
                getargs v1 v2
                /v=a-a//b*b
                arthm v $0 $1 v1 v2
                math floor v v
                arthm v v1 v v2 $-1
                return v
            ]]
        },
        ---@endsection SOURCECLASS
        ---@section built_in 1 MACHINECLASS
        machine={
        },
        ---@endsection MACHINECLASS
    }
    ---@endsection BUILT_INCLASS
}
---@endsection ASMCLASS