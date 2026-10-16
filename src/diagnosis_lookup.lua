-- Validate diagnosis codes using the original two-table lookup order.
local Lookup = {}

-- Build a SQLite string literal by escaping apostrophes in a nonempty code.
-- Table names remain fixed below; input is never used as an SQL identifier.
local function quote(value)
   assert(type(value) == 'string' and value ~= '', 'Diagnosis code must be a nonempty string')
   return "'" .. value:gsub("'", "''") .. "'"
end

-- Search the primary reference table, then the secondary table only if needed.
-- Return the first nonempty Iguana result set, or nil when neither table has a match.
-- The caller owns the open connection; this helper neither opens nor closes it.
function Lookup.find(connection, code)
   -- The table sequence defines precedence when a code occurs in both sources.
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
