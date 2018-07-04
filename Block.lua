local sha2 = require 'sha2'
local hash = sha2.hash224

local Block = {}
Block.__index = Block

setmetatable(Block, {
    -- make syntax Block() equivalent to Block.new()
    __call = function (cls, ...) return cls.new(...) end
})

function Block.genHash (t) --[[
    This function generates a SHA-256 hash using the Block's entire state as
    input for the hashing function. Hypothetically, one therefore cannot create
    exactly the same signature from a block without their new Block having all
    the same values as the Block they're attempting to emulate.
]]--
    local string = ""
    for k,v in pairs(t) do
        string = string
        ..tostring(t.prevHash)
        ..tostring(t.timestamp)
        ..tostring(t.nonce)
        for i=1,#t.data,1 do
            string = string .. tostring(v)
        end
    end
    -- print(string)
    return hash(string)
end

function Block.new (
    prevHash,   -- String
    data        -- Table
) --[[
    'self' will be an empty table with a metatable of 'mt'. Any time you try
    to access data using InstanceName[Key], ('InstanceName' being the name
    of the instance of Block), Lua will traverse the empty table, see that
    the key isn't there, and call the __index or __newindex function. These
    functions will mimic encapsulation of the pseudo-object we're creating.
]]--
    local self = {}
    local mt = setmetatable({}, Block)
    mt.__metatable = mt -- client cannot use setmetatable or getmetatable

        --> DATA FIELDS
        mt.prevHash = prevHash
        mt.timestamp = os.time()
        mt.data = data
        mt.nonce = 0

        --> Hash
        mt.hash = mt:genHash()

        --> FUNCTIONS
        mt.__index = function (tbl,key) --[[
            This function will be called whenever you try to read the Block's
            elements. You can whitelist and blacklist elements with a simple
            if/then/else statement, but for now there's no reason now to make
            all values accessible.
        ]]--
            return mt[key]
        end

        mt.__newindex = function (tbl, key, val) --[[
            This function is called whenever you try to use the assignment
            operator on this table's elements. It prevents the client from
            making any revisions to the Block without using the intended
            functions.
        ]]--
            print (
                "Attempt to illegally write " .. type(tbl) .. " property "
                .. tostring(key) .. " to value " .. tostring(val) .. "."
            )
            return
        end

        mt.proof = function (d) --[[
            A simple proof of work function for the blockchain, where 'd' is the
            difficulty of the challenge
        ]]--
            print('Generating Proof of Work...')
            local targetString = ""
            for i=1, d ,1 do
                targetString = targetString .. "0"
            end

            while string.sub(mt.hash,1,d) ~= targetString do
                mt.nonce = mt.nonce + 1
                mt.hash = mt:genHash()
                print('\tAttempt ' .. mt.nonce .. ': ' .. mt.hash)
            end

            print('FINAL: '..mt.hash)
            return mt.hash
        end

        -- Table Traversal: self{empty} > mt{encapsulated data} > Block{functions}
        setmetatable(self, mt)
    return self
end

return Block
