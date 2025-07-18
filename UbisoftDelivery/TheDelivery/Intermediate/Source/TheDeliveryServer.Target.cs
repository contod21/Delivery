using UnrealBuildTool;

public class TheDeliveryServerTarget : TargetRules
{
	public TheDeliveryServerTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Server;
		ExtraModuleNames.Add("TheDelivery");
	}
}
