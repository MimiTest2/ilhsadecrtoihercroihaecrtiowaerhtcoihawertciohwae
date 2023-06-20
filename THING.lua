--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.2.8) ~  Much Love, Ferib 

]]--

local StrToNumber=tonumber;local Byte=string.byte;local Char=string.char;local Sub=string.sub;local Subg=string.gsub;local Rep=string.rep;local Concat=table.concat;local Insert=table.insert;local LDExp=math.ldexp;local GetFEnv=getfenv or function()return _ENV;end ;local Setmetatable=setmetatable;local PCall=pcall;local Select=select;local Unpack=unpack or table.unpack ;local ToNumber=tonumber;local function VMCall(ByteString,vmenv,...)local DIP=1;local repeatNext;ByteString=Subg(Sub(ByteString,5),"..",function(byte)if (Byte(byte,2)==79) then repeatNext=StrToNumber(Sub(byte,1,1));return "";else local a=Char(StrToNumber(byte,16));if repeatNext then local b=Rep(a,repeatNext);repeatNext=nil;return b;else return a;end end end);local function gBit(Bit,Start,End)if End then local Res=(Bit/(2^(Start-1)))%(2^(((End-1) -(Start-1)) + 1)) ;return Res-(Res%1) ;else local Plc=2^(Start-1) ;return (((Bit%(Plc + Plc))>=Plc) and 1) or 0 ;end end local function gBits8()local a=Byte(ByteString,DIP,DIP);DIP=DIP + 1 ;return a;end local function gBits16()local a,b=Byte(ByteString,DIP,DIP + 2 );DIP=DIP + 2 ;return (b * 256) + a ;end local function gBits32()local a,b,c,d=Byte(ByteString,DIP,DIP + 3 );DIP=DIP + 4 ;return (d * 16777216) + (c * 65536) + (b * 256) + a ;end local function gFloat()local Left=gBits32();local Right=gBits32();local IsNormal=1;local Mantissa=(gBit(Right,1,20) * (2^32)) + Left ;local Exponent=gBit(Right,21,31);local Sign=((gBit(Right,32)==1) and  -1) or 1 ;if (Exponent==0) then if (Mantissa==0) then return Sign * 0 ;else Exponent=1;IsNormal=0;end elseif (Exponent==2047) then return ((Mantissa==0) and (Sign * (1/0))) or (Sign * NaN) ;end return LDExp(Sign,Exponent-1023 ) * (IsNormal + (Mantissa/(2^52))) ;end local function gString(Len)local Str;if  not Len then Len=gBits32();if (Len==0) then return "";end end Str=Sub(ByteString,DIP,(DIP + Len) -1 );DIP=DIP + Len ;local FStr={};for Idx=1, #Str do FStr[Idx]=Char(Byte(Sub(Str,Idx,Idx)));end return Concat(FStr);end local gInt=gBits32;local function _R(...)return {...},Select("#",...);end local function Deserialize()local Instrs={};local Functions={};local Lines={};local Chunk={Instrs,Functions,nil,Lines};local ConstCount=gBits32();local Consts={};for Idx=1,ConstCount do local Type=gBits8();local Cons;if (Type==1) then Cons=gBits8()~=0 ;elseif (Type==2) then Cons=gFloat();elseif (Type==3) then Cons=gString();end Consts[Idx]=Cons;end Chunk[3]=gBits8();for Idx=1,gBits32() do local Descriptor=gBits8();if (gBit(Descriptor,1,1)==0) then local Type=gBit(Descriptor,2,3);local Mask=gBit(Descriptor,4,6);local Inst={gBits16(),gBits16(),nil,nil};if (Type==0) then Inst[3]=gBits16();Inst[4]=gBits16();elseif (Type==1) then Inst[3]=gBits32();elseif (Type==2) then Inst[3]=gBits32() -(2^16) ;elseif (Type==3) then Inst[3]=gBits32() -(2^16) ;Inst[4]=gBits16();end if (gBit(Mask,1,1)==1) then Inst[2]=Consts[Inst[2]];end if (gBit(Mask,2,2)==1) then Inst[3]=Consts[Inst[3]];end if (gBit(Mask,3,3)==1) then Inst[4]=Consts[Inst[4]];end Instrs[Idx]=Inst;end end for Idx=1,gBits32() do Functions[Idx-1 ]=Deserialize();end return Chunk;end local function Wrap(Chunk,Upvalues,Env)local Instr=Chunk[1];local Proto=Chunk[2];local Params=Chunk[3];return function(...)local Instr=Instr;local Proto=Proto;local Params=Params;local _R=_R;local VIP=1;local Top= -1;local Vararg={};local Args={...};local PCount=Select("#",...) -1 ;local Lupvals={};local Stk={};for Idx=0,PCount do if (Idx>=Params) then Vararg[Idx-Params ]=Args[Idx + 1 ];else Stk[Idx]=Args[Idx + 1 ];end end local Varargsz=(PCount-Params) + 1 ;local Inst;local Enum;while true do Inst=Instr[VIP];Enum=Inst[1];if (Enum<=39) then if (Enum<=19) then if (Enum<=9) then if (Enum<=4) then if (Enum<=1) then if (Enum>0) then local A=Inst[2];Stk[A]=Stk[A](Stk[A + 1 ]);else Stk[Inst[2]]=Stk[Inst[3]];end elseif (Enum<=2) then Stk[Inst[2]]=Inst[3];elseif (Enum>3) then do return;end else Stk[Inst[2]]=Inst[3]~=0 ;end elseif (Enum<=6) then if (Enum==5) then if (Stk[Inst[2]]~=Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end else do return Stk[Inst[2]];end end elseif (Enum<=7) then local A=Inst[2];local Cls={};for Idx=1, #Lupvals do local List=Lupvals[Idx];for Idz=0, #List do local Upv=List[Idz];local NStk=Upv[1];local DIP=Upv[2];if ((NStk==Stk) and (DIP>=A)) then Cls[DIP]=NStk[DIP];Upv[1]=Cls;end end end elseif (Enum>8) then Stk[Inst[2]]=Env[Inst[3]];else local NewProto=Proto[Inst[3]];local NewUvals;local Indexes={};NewUvals=Setmetatable({},{__index=function(_,Key)local Val=Indexes[Key];return Val[1][Val[2]];end,__newindex=function(_,Key,Value)local Val=Indexes[Key];Val[1][Val[2]]=Value;end});for Idx=1,Inst[4] do VIP=VIP + 1 ;local Mvm=Instr[VIP];if (Mvm[1]==72) then Indexes[Idx-1 ]={Stk,Mvm[3]};else Indexes[Idx-1 ]={Upvalues,Mvm[3]};end Lupvals[ #Lupvals + 1 ]=Indexes;end Stk[Inst[2]]=Wrap(NewProto,NewUvals,Env);end elseif (Enum<=14) then if (Enum<=11) then if (Enum==10) then if (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end else local A=Inst[2];local B=Stk[Inst[3]];Stk[A + 1 ]=B;Stk[A]=B[Inst[4]];end elseif (Enum<=12) then local A=Inst[2];local T=Stk[A];for Idx=A + 1 ,Inst[3] do Insert(T,Stk[Idx]);end elseif (Enum>13) then local A=Inst[2];local Results,Limit=_R(Stk[A](Stk[A + 1 ]));Top=(Limit + A) -1 ;local Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end else Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];end elseif (Enum<=16) then if (Enum>15) then Upvalues[Inst[3]]=Stk[Inst[2]];else local A=Inst[2];Stk[A]=Stk[A]();end elseif (Enum<=17) then Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];elseif (Enum==18) then do return Stk[Inst[2]];end else local NewProto=Proto[Inst[3]];local NewUvals;local Indexes={};NewUvals=Setmetatable({},{__index=function(_,Key)local Val=Indexes[Key];return Val[1][Val[2]];end,__newindex=function(_,Key,Value)local Val=Indexes[Key];Val[1][Val[2]]=Value;end});for Idx=1,Inst[4] do VIP=VIP + 1 ;local Mvm=Instr[VIP];if (Mvm[1]==72) then Indexes[Idx-1 ]={Stk,Mvm[3]};else Indexes[Idx-1 ]={Upvalues,Mvm[3]};end Lupvals[ #Lupvals + 1 ]=Indexes;end Stk[Inst[2]]=Wrap(NewProto,NewUvals,Env);end elseif (Enum<=29) then if (Enum<=24) then if (Enum<=21) then if (Enum==20) then local A=Inst[2];Stk[A]=Stk[A](Stk[A + 1 ]);else Stk[Inst[2]]=Stk[Inst[3]][Inst[4]];end elseif (Enum<=22) then Stk[Inst[2]]={};elseif (Enum==23) then Stk[Inst[2]]();else local A=Inst[2];Stk[A](Stk[A + 1 ]);end elseif (Enum<=26) then if (Enum==25) then local A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Top));end else Stk[Inst[2]]=Upvalues[Inst[3]];end elseif (Enum<=27) then Stk[Inst[2]]={};elseif (Enum==28) then local A=Inst[2];Stk[A](Stk[A + 1 ]);else for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end end elseif (Enum<=34) then if (Enum<=31) then if (Enum>30) then local A=Inst[2];local Results={Stk[A](Unpack(Stk,A + 1 ,Top))};local Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end else Env[Inst[3]]=Stk[Inst[2]];end elseif (Enum<=32) then Upvalues[Inst[3]]=Stk[Inst[2]];elseif (Enum==33) then local A=Inst[2];local T=Stk[A];local B=Inst[3];for Idx=1,B do T[Idx]=Stk[A + Idx ];end else Stk[Inst[2]]=Upvalues[Inst[3]];end elseif (Enum<=36) then if (Enum>35) then local A=Inst[2];Stk[A](Unpack(Stk,A + 1 ,Inst[3]));else local A=Inst[2];do return Unpack(Stk,A,A + Inst[3] );end end elseif (Enum<=37) then Stk[Inst[2]]=Wrap(Proto[Inst[3]],nil,Env);elseif (Enum==38) then local A=Inst[2];do return Stk[A](Unpack(Stk,A + 1 ,Top));end elseif (Stk[Inst[2]]~=Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=59) then if (Enum<=49) then if (Enum<=44) then if (Enum<=41) then if (Enum==40) then local A=Inst[2];local T=Stk[A];for Idx=A + 1 ,Top do Insert(T,Stk[Idx]);end else local A=Inst[2];local Results={Stk[A](Unpack(Stk,A + 1 ,Top))};local Edx=0;for Idx=A,Inst[4] do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end end elseif (Enum<=42) then local A=Inst[2];do return Unpack(Stk,A,Top);end elseif (Enum==43) then if  not Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end else local A=Inst[2];local Cls={};for Idx=1, #Lupvals do local List=Lupvals[Idx];for Idz=0, #List do local Upv=List[Idz];local NStk=Upv[1];local DIP=Upv[2];if ((NStk==Stk) and (DIP>=A)) then Cls[DIP]=NStk[DIP];Upv[1]=Cls;end end end end elseif (Enum<=46) then if (Enum>45) then Stk[Inst[2]]=Wrap(Proto[Inst[3]],nil,Env);else local A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));end elseif (Enum<=47) then local A=Inst[2];do return Unpack(Stk,A,Top);end elseif (Enum>48) then local A=Inst[2];Stk[A]=Stk[A]();else Stk[Inst[2]]=Inst[3]~=0 ;end elseif (Enum<=54) then if (Enum<=51) then if (Enum>50) then local A=Inst[2];local T=Stk[A];local B=Inst[3];for Idx=1,B do T[Idx]=Stk[A + Idx ];end else local A=Inst[2];local T=Stk[A];for Idx=A + 1 ,Top do Insert(T,Stk[Idx]);end end elseif (Enum<=52) then if (Stk[Inst[2]]==Stk[Inst[4]]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum==53) then local A=Inst[2];Stk[A]=Stk[A](Unpack(Stk,A + 1 ,Inst[3]));else do return;end end elseif (Enum<=56) then if (Enum>55) then if (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end else local A=Inst[2];local C=Inst[4];local CB=A + 2 ;local Result={Stk[A](Stk[A + 1 ],Stk[CB])};for Idx=1,C do Stk[CB + Idx ]=Result[Idx];end local R=Result[1];if R then Stk[CB]=R;VIP=Inst[3];else VIP=VIP + 1 ;end end elseif (Enum<=57) then VIP=Inst[3];elseif (Enum>58) then local A=Inst[2];local C=Inst[4];local CB=A + 2 ;local Result={Stk[A](Stk[A + 1 ],Stk[CB])};for Idx=1,C do Stk[CB + Idx ]=Result[Idx];end local R=Result[1];if R then Stk[CB]=R;VIP=Inst[3];else VIP=VIP + 1 ;end else Stk[Inst[2]][Inst[3]]=Inst[4];end elseif (Enum<=69) then if (Enum<=64) then if (Enum<=61) then if (Enum>60) then local A=Inst[2];local Results,Limit=_R(Stk[A](Stk[A + 1 ]));Top=(Limit + A) -1 ;local Edx=0;for Idx=A,Top do Edx=Edx + 1 ;Stk[Idx]=Results[Edx];end else Stk[Inst[2]]();end elseif (Enum<=62) then if  not Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum>63) then local A=Inst[2];Stk[A](Unpack(Stk,A + 1 ,Inst[3]));else for Idx=Inst[2],Inst[3] do Stk[Idx]=nil;end end elseif (Enum<=66) then if (Enum>65) then if (Stk[Inst[2]]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Inst[2]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=67) then Stk[Inst[2]]=Env[Inst[3]];elseif (Enum==68) then local A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do local VA=Vararg[Idx-A ];Stk[Idx]=VA;end elseif Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=74) then if (Enum<=71) then if (Enum==70) then Stk[Inst[2]]=Inst[3];else VIP=Inst[3];end elseif (Enum<=72) then Stk[Inst[2]]=Stk[Inst[3]];elseif (Enum>73) then Stk[Inst[2]][Inst[3]]=Stk[Inst[4]];elseif (Inst[2]==Inst[4]) then VIP=VIP + 1 ;else VIP=Inst[3];end elseif (Enum<=76) then if (Enum>75) then if Stk[Inst[2]] then VIP=VIP + 1 ;else VIP=Inst[3];end else local A=Inst[2];Top=(A + Varargsz) -1 ;for Idx=A,Top do local VA=Vararg[Idx-A ];Stk[Idx]=VA;end end elseif (Enum<=77) then Stk[Inst[2]][Inst[3]]=Inst[4];elseif (Enum==78) then local A=Inst[2];local B=Stk[Inst[3]];Stk[A + 1 ]=B;Stk[A]=B[Inst[4]];else Env[Inst[3]]=Stk[Inst[2]];end VIP=VIP + 1 ;end end;end return Wrap(Deserialize(),{},vmenv)(...);end VMCall("LOL!013O0003063O00787063612O6C00053O0012433O00013O00022E00015O00022E000200014O00403O000200012O00043O00013O00023O002B3O0003123O0070726F6A6563747261692O6E65772E6C7561028O0003063O00787063612O6C03043O007761726E03063O0067657468756903043O0067616D65030A3O004765745365727669636503073O00436F726547756903073O0067657467656E7603113O0048494748434F4E464944454E43454649582O01030C3O0057616974466F724368696C64030C3O007569206C69622074773O6F023O00C088C3004203093O0043617465676F72797303083O007363616E436F7265030C3O007363616E46616B65436F7265030F3O0044657363656E64616E74412O64656403073O00436F2O6E65637403053O007061697273030E3O0047657444657363656E64616E74732O033O00497341030A3O00496D6167654C6162656C03053O00496D61676503043O0066696E64030B3O00726278612O7365743A2O2F03053O007461626C6503063O00696E73657274030C3O00682O6F6B66756E6374696F6E030F3O00436F6E74656E7450726F7669646572030C3O005072656C6F61644173796E63030E3O00682O6F6B6D6574616D6574686F64030A3O002O5F6E616D6563612O6C03073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B031C3O0050726F6A656374207061696E2068617320622O656E20666F756E642E03043O007461736B03043O007761697403023O005F4703053O0075726B657903063O00464C55585553030D3O00676F206177617920636974616D00C04O001B3O00013O001246000100014O00213O00010001001246000100023O001243000200033O00022E00035O001243000400044O0040000200040001001243000200053O00064C0002000F00013O0004393O000F0001001243000200054O000F00020001000200063E00020013000100010004393O00130001001243000200063O00204E000200020007001246000400084O002D0002000400022O000300035O001243000400094O000F00040001000200303A0004000A000B00204E00040002000C0012460006000D3O0012460007000E4O002D0004000700022O000300056O000300066O000300076O000300085O00064C000400B700013O0004393O00B7000100204E00090004000C001246000B000F4O002D0009000B000200064C000900B700013O0004393O00B7000100060800090001000100012O00483O00083O00124F000900103O00060800090002000100012O00483O00083O00124F000900113O001243000900063O00204E000900090007001246000B00084O002D0009000B000200201500090009001200204E000900090013001243000B00104O00400009000B0001001243000900063O00201500090009000800201500090009001200204E000900090013001243000B00114O00400009000B0001001243000900143O001243000A00063O002015000A000A000800204E000A000A00152O003D000A000B4O002900093O000B0004393O00440001001243000E00116O000F000D4O001C000E0002000100063700090041000100020004393O00410001001243000900143O001243000A00063O00204E000A000A0007001246000C00084O002D000A000C000200204E000A000A00152O003D000A000B4O002900093O000B0004393O00520001001243000E00106O000F000D4O001C000E000200010006370009004F000100020004393O004F0001001243000900143O00204E000A000200152O003D000A000B4O002900093O000B0004393O005C0001001243000E00106O000F000D4O001C000E0002000100063700090059000100020004393O00590001002E49000B00450001000B0004393O00A3000100063E0008009B000100010004393O009B0001001243000900063O00204E000900090007001246000B00084O002D0009000B00022O001B000A5O001243000B00143O002015000C000900154O000D00094O003D000C000D4O0029000B3O000D0004393O007E00010020150010000F00164O0011000F3O001246001200174O002D00100012000200064C0010007E00013O0004393O007E00010020150010000F001800204E0010001000190012460012001A4O002D00100012000200064C0010007E00013O0004393O007E00010012430010001B3O00201500100010001C4O0011000A3O0020150012000F00182O0040001000120001000637000B006D000100020004393O006D00012O003F000B000B3O001243000C001D3O001243000D00063O00204E000D000D0007001246000F001E4O002D000D000F0002002015000D000D001F000608000E0003000100032O00483O00094O00483O000A4O00483O000B4O002D000C000E00024O000B000C3O00022E000C00044O003F000D000D3O001243000E00203O001243000F00063O001246001000213O00060800110005000100042O00483O00094O00483O000C4O00483O000A4O00483O000D4O002D000E001100024O000D000E4O002C00095O0004393O00A30001001243000900063O00204E000900090007001246000B00224O002D0009000B000200201500090009002300204E000900090024001246000B00254O00400009000B000100063E000800AE000100010004393O00AE0001001243000900263O0020150009000900272O003C000900010001001243000900283O002015000900090029002642000900A30001002A0004393O00A300012O0003000800013O0004393O00A30001001243000900063O00204E000900090007001246000B00224O002D0009000B000200201500090009002300204E000900090024001246000B00254O00400009000B00010004393O00BF0001001243000900063O00204E000900090007001246000B00224O002D0009000B000200201500090009002300204E000900090024001246000B002B4O00400009000B00012O00043O00013O00063O000B3O0003043O0067616D65030B3O0043726561746F725479706503043O00456E756D03053O0047726F757003093O0043726561746F724964023O0080AEE25341030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B030F3O004E6F7420642O657020776F6B656E2E00153O0012433O00013O0020155O0002001243000100033O00201500010001000200201500010001000400060A3O0014000100010004393O001400010012433O00013O0020155O00050026053O0014000100060004393O001400010012433O00013O00204E5O0007001246000200084O002D3O000200020020155O000900204E5O000A0012460002000B4O00403O000200012O00043O00014O00043O00017O00013O0003053O007063612O6C01063O001243000100013O00060800023O000100022O00488O001A8O001C0001000200012O00043O00013O00013O00103O0003043O004E616D65030A3O0074616273486F6C64657203043O0054657874030B3O0043686174204C6F2O67657203103O006E657753656374696F6E426F7264657203123O006F757473696465426F726465724869646572030C3O0050726F6A656374205061696E03053O00496D61676503173O00726278612O73657469643A2O2F3133323730383736343203173O00726278612O73657469643A2O2F323435342O303930323603043O0067616D65030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B033B3O005061696E2044657465637465642E20506C6561736520646F206E6F74207573652070726F6A656374207061696E206173207468657920736B69642E00274O00227O0020155O00010026053O001C000100020004393O001C00012O00227O0020155O00030026053O001C000100040004393O001C00012O00227O0020155O00010026053O001C000100050004393O001C00012O00227O0020155O00010026053O001C000100060004393O001C00012O00227O0020155O00030026053O001C000100070004393O001C00012O00227O0020155O00080026053O001C000100090004393O001C00012O00227O0020155O00080026423O00260001000A0004393O002600010012433O000B3O00204E5O000C0012460002000D4O002D3O000200020020155O000E00204E5O000F001246000200104O00403O000200012O00033O00014O00103O00014O00043O00017O00013O0003053O007063612O6C01063O001243000100013O00060800023O000100022O00488O001A8O001C0001000200012O00043O00013O00013O00173O0003043O004E616D6503063O00466F6C64657203343O004C612O6E6973205B5261672O6F7A65725D3A20686920696D207265616C207261672O6F7A657220526F677565204C696E65616765030A3O004B692O6C427269636B73030A3O0074616273486F6C64657203043O0054657874030B3O0043686174204C6F2O67657203013O00762O033O00497341030A3O00496D6167654C6162656C03063O0062752O746F6E03103O006E657753656374696F6E426F7264657203123O006F757473696465426F726465724869646572030C3O0050726F6A656374205061696E03053O00496D61676503173O00726278612O73657469643A2O2F3133323730383736343203173O00726278612O73657469643A2O2F323435342O303930323603043O0067616D65030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B033B3O005061696E2044657465637465642E20506C6561736520646F206E6F74207573652070726F6A656374207061696E206173207468657920736B69642E00394O00227O0020155O00010026053O000C000100020004393O000C00012O00227O0020155O00010026053O000C000100030004393O000C00012O00227O0020155O00010026423O000E000100040004393O000E00012O00033O00014O00103O00014O00227O00201500013O00010026050001002E000100050004393O002E000100201500013O00060026050001002E000100070004393O002E0001001243000100083O00204E0001000100090012460003000A4O002D00010003000200064C0001001F00013O0004393O001F0001001243000100083O0020150001000100010026050001002E0001000B0004393O002E000100201500013O00010026050001002E0001000C0004393O002E000100201500013O00010026050001002E0001000D0004393O002E000100201500013O00060026050001002E0001000E0004393O002E000100201500013O000F0026050001002E000100100004393O002E000100201500013O000F00264200010038000100110004393O00380001001243000100123O00204E000100010013001246000300144O002D00010003000200201500010001001500204E000100010016001246000300174O00400001000300012O0003000100014O0010000100014O00043O00017O00063O00030B3O00636865636B63612O6C657203043O0074797065026O00F03F03053O007461626C6503043O0066696E6403063O00756E7061636B01224O001B00026O004400036O002800023O0001001243000300014O000F00030001000200063E0003001C000100010004393O001C0001001243000300023O0020150004000200032O00010003000200020026420003001C000100040004393O001C0001001243000300043O0020150003000300050020150004000200032O002200056O002D00030005000200064C0003001C00013O0004393O001C00012O0022000300013O00104A0002000300032O0022000300026O00045O001243000500066O000600024O003D000500064O001900036O002A00036O0022000300026O00046O004400056O001900036O002A00036O00043O00017O00023O00030C3O005072656C6F61644173796E63030C3O007072656C6F61644173796E6301093O0026053O0004000100010004393O000400010026423O0006000100020004393O000600012O0003000100014O0006000100024O000300016O0006000100024O00043O00017O000A3O0003113O006765746E616D6563612O6C6D6574686F64030B3O00636865636B63612O6C657203043O0074797065026O00F03F03053O007461626C6503043O0066696E6403043O0067616D65030A3O0047657453657276696365030F3O00436F6E74656E7450726F766964657203063O00756E7061636B01304O001B00026O004400036O002800023O0001001243000300014O000F000300010002001243000400024O000F00040001000200063E0004002A000100010004393O002A0001001243000400033O0020150005000200042O00010004000200020026420004002A000100050004393O002A0001001243000400053O0020150004000400060020150005000200042O002200066O002D00040006000200064C0004002A00013O0004393O002A0001001243000400073O002015000400040008001243000500073O001246000600094O002D00040006000200060A3O002A000100040004393O002A00012O0022000400016O000500034O000100040002000200064C0004002A00013O0004393O002A00012O0022000400023O00104A0002000400042O0022000400036O00055O0012430006000A6O000700024O003D000600074O001900046O002A00046O0022000400036O00056O004400066O001900046O002A00046O00043O00017O00063O0003043O0067616D65030A3O004765745365727669636503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B03263O004869676820436F6E666964656E636520427970612O73204661696C656420546F204C6F61642E00093O0012433O00013O00204E5O0002001246000200034O002D3O000200020020155O000400204E5O0005001246000200064O00403O000200012O00043O00017O00",GetFEnv(),...);
