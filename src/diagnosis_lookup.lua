-- Validate diagnosis codes using the original two-table lookup order.
local Lookup = {}

local function quote(value)
   assert(type(value) == 'string' and value ~= '', 'Diagnosis code must be a nonempty string')
   return "'" .. value:gsub("'", "''") .. "'"
end

function Lookup.find(connection, code)
   for _, tableName in ipairs({'DG_Codes_1500', 'DG_Codes_72500'}) do
      local rows = connection:query{
         sql = 'SELECT DG_Description FROM ' .. tableName ..
            ' WHERE DG_Codes = ' .. quote(code),
         live = true
      }
      if #rows > 0 then
         return rows
      end
   end
   return nil
end

return Lookup
