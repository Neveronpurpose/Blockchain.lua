local Block = require 'Block'
local sha2 = require 'sha2'
local hash = sha2.hash224

local Blockchain = {}
Blockchain.__index = Blockchain

setmetatable(Blockchain, {
    -- calling Blockchain() is the same as Blockchain.new()
    __call = function (cls, ...) return Blockchain.new (cls, ...) end
})

Blockchain.new = function ()
    local self = {}
    local mt = setmetatable({}, Blockchain)

    -- holds the blocks
    mt.sequence = {}

    mt.__index = function (tbl,key)
        -- this function prevents reading the blockchain's data without passing
        -- through this function, so you can add access qualifications here
        return mt[key]
    end

    mt.__newindex = function (tbl, key, val)
        -- this function prevents any of the elements in the table from being overwritten
        print (
            "Attempt to illegally write "..type(tbl).." property "
            .. tostring(key) .. " to value " .. tostring(val) .. "."
        )
        return
    end

    -- create a genesis block
    mt.sequence[1] = Block(0, {})

    setmetatable(self,mt)
    return self
end

Blockchain.validate = function (
    t,  -- table: blockchain being validated
    d   -- (optional) int: difficulty of the proof
)
    print('\nValidating Blockchain...')
    -- for each block...
    for i=1, #t.sequence, 1 do
        -- check that current.hash is correct based on its state
        local check = getmetatable(t.sequence[i]):genHash()
        if t.sequence[i].hash ~= check then
            print("VALIDATION FAILED "..'['..i..']'..": invalid hash "..check..".")
            return false
        end
        print("\tHash valid.")

        -- check current.prevHash == previous.hash
        if t.sequence[i].prevHash ~= 0 then -- check if this is the Genesis block
            if t.sequence[i].prevHash ~= t.sequence[i-1].hash then
                print("VALIDATION FAILED "..'['..i..']'..": previous hash mismatch.")
                return false
            end
        else -- if this is the Genesis block, it should be at the start of the sequence
            if i ~= 1 then
                print("VALIDATION FAILED "..'['..i..']'..": prevHash=0 on a non-genesis block.")
                return false
            end
        end
        print("\tPrevHash valid.")

        -- check that the hash meets the Proof of Work challenge
        if d ~= nil then
            local targetString = ""
            for i=1, d ,1 do
                targetString = targetString .. "0"
            end

            if string.sub(t.sequence[i].hash,1,d) ~= targetString then
                print("VALIDATION FAILED "..'['..i..']'..": hash does not meet Proof of Work requirements.")
    			return false
            end
        end
        print("\tProof of Work confirmed.")
    end

    print("\nBlockchain successfully validated.")
    return true
end

return Blockchain
