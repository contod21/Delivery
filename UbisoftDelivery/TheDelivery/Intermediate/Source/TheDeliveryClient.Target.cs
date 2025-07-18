using UnrealBuildTool;

public class TheDeliveryClientTarget : TargetRules
{
	public TheDeliveryClientTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Client;
		ExtraModuleNames.Add("TheDelivery");
	}
}
