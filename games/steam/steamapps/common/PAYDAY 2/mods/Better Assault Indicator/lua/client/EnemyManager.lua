managers.enemy.force_spawned = 0
BAI:Hook(EnemyManager, "on_enemy_registered", function(self, ...)
    self.force_spawned = self.force_spawned + 1
end)