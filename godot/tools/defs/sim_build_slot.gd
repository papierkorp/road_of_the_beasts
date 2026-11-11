class_name SimBuildSlot
extends Resource
## One kit slot of a test build: the priced skill and the slot level whose ceiling it must fit
## (gdd_skills §5 working draft: 24 / 30 / 36 construction points at slot level 1 / 2 / 3).

@export var record: PriceRecord
@export_range(1, 3) var level: int = 1
