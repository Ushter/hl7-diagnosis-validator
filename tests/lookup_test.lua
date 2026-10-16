package.path = 'src/?.lua;' .. package.path
local lookup = require 'diagnosis_lookup'
local queries = {}
local connection = {}
function connection:query(options)
   queries[#queries + 1] = options.sql
   if options.sql:find('diagnosis_secondary', 1, true) then
      return {{description = 'Synthetic description'}}
   end
   return {}
end
assert(lookup.find(connection, "TEST'CODE"))
assert(#queries == 2)
assert(queries[1]:find("TEST''CODE", 1, true))
queries = {}
function connection:query(options)
   queries[#queries + 1] = options.sql
   return {{description = 'Synthetic description'}}
end
assert(lookup.find(connection, 'TEST-CODE'))
assert(#queries == 1)
function connection:query() return {} end
assert(lookup.find(connection, 'UNKNOWN') == nil)
assert(not pcall(lookup.find, connection, ''))
