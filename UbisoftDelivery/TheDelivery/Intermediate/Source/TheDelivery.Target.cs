using UnrealBuildTool;

public class TheDeliveryTarget : TargetRules
{
	public TheDeliveryTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Game;
		ExtraModuleNames.Add("TheDelivery");
	}
}
