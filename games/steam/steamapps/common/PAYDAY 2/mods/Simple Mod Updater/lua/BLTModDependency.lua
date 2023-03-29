local smu_original_bltmoddependency_getserverhash = BLTModDependency.GetServerHash
function BLTModDependency:GetServerHash()
	if self.is_simple_dependency then
		return SimpleModUpdater.fake_hash
	end
	return smu_original_bltmoddependency_getserverhash( self )
end

function BLTModDependency:UsesHash()
	return self.is_simple_dependency
end

function BLTModDependency:ViewPatchNotes()
	if self.is_simple_dependency then
		return -- changelog url can't be known for dependencies
	else
		BLTUpdate.ViewPatchNotes( self )
	end
end

function BLTModDependency:GetPatchNotes()
	-- qued
end
