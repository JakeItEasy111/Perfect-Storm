extends Node

signal on_item_picked_up(item)
signal on_upgrade_picked_up(item)
signal on_pickup(item)
signal equip_item(slot)
signal action_timer_begin(action_time)
signal action_timer_end(cooldown_time)
signal action_timer_complete()
signal use_equipped_item(slot)
signal item_used(item)
signal status_applied(status)
