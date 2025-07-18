using UnrealBuildTool;

public class TheDeliveryEditorTarget : TargetRules
{
	public TheDeliveryEditorTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Editor;
		ExtraModuleNames.Add("TheDelivery");
	}
}
