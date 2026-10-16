-- Parse incoming HL7 and report diagnosis codes absent from both lookup tables.
local Lookup = require 'diagnosis_lookup'

-- Validate one incoming HL7 message using a configured VMD and SQLite reference data.
-- Queue unknown diagnoses as structured JSON; raise a generic error on lookup failure.
function main(Data)
   assert(type(Data) == 'string' and Data ~= '', 'Expected an HL7 message')
   -- Paths are supplied by the deployment instead of embedding personal machine locations.
   local databasePath = assert(os.getenv('DIAGNOSIS_DB_PATH'), 'Set DIAGNOSIS_DB_PATH')
   local vmdPath = assert(os.getenv('HL7_VMD_PATH'), 'Set HL7_VMD_PATH')
   -- The chosen VMD must expose repeated DG1 segments. DG1-3.1 contains the code;
   -- DG1-3.2 supplies its accompanying description.
   local message = hl7.parse{data = Data, vmd = vmdPath}
   local connection = db.connect{api = db.SQLITE, name = databasePath, live = true}

   -- Run all database lookups inside a protected call so cleanup runs after a query error.
   local ok, result = pcall(function()
      local unknown = {}
      for i = 1, #message.DG1 do
         local code = message.DG1[i][3][1]:nodeValue()
         -- Only unmatched codes enter the report. A reference-table hit omits this DG1
         -- from unknownDiagnoses; an empty report means all examined codes were found.
         if not Lookup.find(connection, code) then
            unknown[#unknown + 1] = {
               segmentIndex = i,
               code = code,
               description = message.DG1[i][3][2]:nodeValue()
            }
         end
      end
      return {unknownDiagnoses = unknown}
   end)
   -- Close before propagating lookup failures or serializing/queuing the result.
   connection:close()
   assert(ok, 'Diagnosis validation failed')
   -- Queue only the validation result; do not log or embed patient messages.
   queue.push{data = json.serialize{data = result}}
end
