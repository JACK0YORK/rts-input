local button={
    type = "custom-input",
    name = "move-to-cursor",
    key_sequence = "SHIFT + G",
    consuming = "none"
}
data:extend{button}

local horizontal_animation = {
    type="animation",
    filename = "__base__/graphics/entity/beam/hr-tileable-beam-END-light.png",
    name= "horizontal_animation",
    width = 91,
    height = 93,
    frame_count = 16,
    line_length = 4
    -- shift = {0.03125, -0.15625}
  }
data:extend{horizontal_animation}

local w={
  type = "custom-input",
  name = "escape-w",
  key_sequence = "W",
  consuming = "none"
}
local a={
  type = "custom-input",
  name = "escape-a",
  key_sequence = "A",
  consuming = "none"
}
local s={
  type = "custom-input",
  name = "escape-s",
  key_sequence = "S",
  consuming = "none"
}
local d={
  type = "custom-input",
  name = "escape-d",
  key_sequence = "D",
  consuming = "none"
}

data:extend{w, a, s, d}