extends CommandQueryHandler
class_name SettingsHandler

@export var repository: SettingsRepository

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is GetSettingsQuery:
		return repository.get_setting(dispatchable.setting)

	return null

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is GetSettingsQuery
