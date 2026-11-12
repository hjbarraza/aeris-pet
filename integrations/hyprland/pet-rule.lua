-- Desktop pet overlay (aeris-pet, aeris-crumbs): full-screen transparent windows. Without
-- no_blur Hyprland blurs everything behind them, so every window looks out of focus;
-- without no_focus a click on the pet moves keyboard focus to a window that ignores keys.
hl.window_rule({
    name  = "aeris-pet-overlay",
    match = { class = "^aeris-(pet|crumbs)$" },

    float       = true,
    no_focus    = true,      -- never takes the keyboard
    no_blur     = true,
    no_shadow   = true,
    no_dim      = true,
    no_anim     = true,
    border_size = 0,
    rounding    = 0,
    opacity     = "1.0 override 1.0 override",
})
