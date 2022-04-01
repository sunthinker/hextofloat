--[[
Hex(4bytes) convert to float (IEEE754)
(-1)^s*2^e*(1.M)
(-1)^s*2^e*(0.M)
b31 b30 b29 b28 b27 b26 b25 b24 b23 b22 b21 b20 b19 b18 b17 b16 b15 b14 b13 b12 b11 b10 b09 b08 b07 b06 b05 b04 b03 b02 b01 b00 
 |   |                           |   |                                                                                       |
 s   |                           |   |                                                                                       |
     |             E             |   |                                                                                       |
                                 |   |                                         M                                             |
]]
function hex_to_float(b1,b2,b3,b4)
    local t1, t2, t3 = b2, b3, b4
    local str, str1, str2, str3 = "", "", "", ""
    local sign = 0
    --sign bit
    if (b1 & 0x80) == 0x80 then
        sign = -1
    else
        sign = 1
    end
    --convert b2b3b4 to binary string
    for i = 1, 8, 1 do
        local s1, s2, s3 = t1 % 2, t2 % 2, t3 %2
        if s1 == 1 then
            str1 = "1"..str1
        else
            str1 = "0"..str1
        end
        if s2 == 1 then
            str2 = "1"..str2
        else
            str2 = "0"..str2
        end
        if s3 == 1 then
            str3 = "1"..str3
        else
            str3 = "0"..str3
        end
        t1, t2, t3 = math.floor(t1/2), math.floor(t2/2), math.floor(t3/2)
    end
    --this is M(magnitude portion)
    str = str1..str2..str3
    --this is E
    local p = ((b1 << 1) &0xFF) + (b2 >> 7)
    if p >= 0 and p < 255 then
        local implied, e = "", 0
        --implied is 0，e = 1-127
        if p == 0 then
            implied, e = "0", 1-127
        --implied is 1, e = E-127 
        else
            implied, e = "1",  p - 127
        end
        --add implied bit
        str = implied .. string.sub(str,2)
        local integers, decimals = 0, 0
        --integers>0
        if e >= 0 then
            --No decimal part
            if e >= 23 then
                decimals = 0
                for i = 1, e-23 do
                    str = str .. "0"
                end 
                integers = tonumber(str,2)
            else 
                local istr = string.sub(str,1,e+1)
                integers = tonumber(istr, 2)
                local dstr = string.sub(str,e+2)
                for i=1,#dstr,1 do
                    b = string.sub(dstr,i,i)
                    if b == "1" then
                        decimals = decimals + 1/(2^i)
                    end
                end
            end
        --integers==0
        else
            integers = 0
            local dstr = str
            for i=-e,-e+#dstr-1,1 do
                b = string.sub(dstr,i+e+1,i+e+1)
                if b == "1" then
                    decimals = decimals + 1/(2^i)
                end
            end
        end
        return (integers+decimals) * sign
    else
        return nil
    end
end


-- ############# test #########################
-- -0.123
print("reference value: -0.123")
local v1 = hex_to_float(0xBD, 0xFB, 0xE7, 0x6C)
print("calc value: ", v1)
print("--------------------------------------")

-- -0.125
print("reference value: -0.125")
local v2 = hex_to_float(0xBE, 0x00, 0x00, 0x00)
print("calc value: ", v2)
print("--------------------------------------")

-- 3.4e-38
print("reference value: 3.4e-38")
local v3 = hex_to_float(0x01, 0x39, 0x1D, 0x15)
print("calc value: ", v3)
print("--------------------------------------")

-- 1023.33
print("reference value: 1023.33")
local v4 = hex_to_float(0x44, 0x7F, 0xD5, 0x1E)
print("calc value: ", v4)
print("--------------------------------------")
