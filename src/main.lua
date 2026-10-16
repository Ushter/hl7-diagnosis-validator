-- Parse incoming HL7 and report diagnosis codes absent from both lookup tables.
local Lookup = require 'diagnosis_lookup'

function main(Data)
   assert(type(Data) == 'string' and Data ~= '', 'Expected an HL7 message')
   local databasePath = assert(os.getenv('DIAGNOSIS_DB_PATH'), 'Set DIAGNOSIS_DB_PATH')
   local vmdPath = assert(os.getenv('HL7_VMD_PATH'), 'Set HL7_VMD_PATH')
   local message = hl7.parse{data = Data, vmd = vmdPath}
   local connection = db.connect{api = db.SQLITE, name = databasePath, live = true}

   local ok, result = pcall(function()
      local unknown = {}
      for i = 1, #message.DG1 do
         local code = message.DG1[i][3][1]:nodeValue()
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
   connection:close()
   assert(ok, 'Diagnosis validation failed')
   -- Queue only the validation result; do not log or embed patient messages.
   queue.push{data = json.serialize{data = result}}
end
