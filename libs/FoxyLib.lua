-----------------------------------------------------------------------------------------------
-- FoxyLib Definition
-- Library for common methods used by my addons
-- Copyright (c) Foxykeep. All rights reserved
-- Layout of the library is based on CassPkg from CasstielCupcake.
-----------------------------------------------------------------------------------------------
local FoxyLib = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- FoxyLib OnLoad
-----------------------------------------------------------------------------------------------
function FoxyLib:OnLoad()
	-- called when all dependencies are loaded. If something has gone wrong, you should return
	-- a string with
	-- if something has gone wrong, return a string with
	-- the strError that will be passed to YOUR dependencies
end

function FoxyLib:OnDependencyError(strDep, strError)
	-- if you don't care about this dependency, return true.
	-- if you return false, or don't define this function
	-- any Addons/Packages that list you as a dependency
	-- will also receive a dependency error
	return false
end


-----------------------------------------------------------------------------------------------
-- FoxyLib functions
-----------------------------------------------------------------------------------------------

function FoxyLib.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[FoxyLib.DeepCopy(orig_key)] = FoxyLib.DeepCopy(orig_value)
        end
        setmetatable(copy, FoxyLib.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function FoxyLib.NullToZero(d)
	if d == nil then
		return 0
	end
	return d
end

-----------------------------------------------------------------------------------------------\
-- FoxyLib locale functions
-----------------------------------------------------------------------------------------------

--
-- Returns:
-- * 1 for English
-- * 2 for French
-- * 3 for German
-- * nil otherwise
function FoxyLib.GetLocale()
	local cancelString = Apollo.GetString(1)
	if cancelString == "Cancel" then
		return 1
	elseif cancelString == "Annuler" then
		return 2
	elseif cancelString == "Abbrechen" then
		return 3
	else
		return nil
	end
end

-----------------------------------------------------------------------------------------------
-- FoxyLib Instance
-----------------------------------------------------------------------------------------------
-- Params are addon, major version, minor version, dependencies
Apollo.RegisterPackage(FoxyLib, "FoxyLib-1.0", 1, {})
