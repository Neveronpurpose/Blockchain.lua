local Block = require 'Block'

    print "Okay, running testfile.lua\n"

    local item = {
        name = "Longsword +1",
        atk_dmg = 71,
        atk_spd = 0.5
    }

    local Genesis = Block(0, {"Hello, World!"})
    local GenJr = Block(Genesis.hash, item)

    -- DEBUG: try to assign a new value to the hash from the client
    -- Genesis.hash = "Reassigned from client." -- doesn't work!

    -- DEBUG: try to append the table with properties not included at instantiation
    -- Genesis.x = 0 -- doesn't work!

    print('BLOCK: GenJr')
    print('Initial Hash: ' .. GenJr.hash .. '\n')

    local difficulty = 5

    print('Challenge: ' .. difficulty)
    print('Generating a proof...')
    GenJr.proof(difficulty)
    print('New Hash: '..GenJr.hash..'\n')
