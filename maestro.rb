#!ruby
require_relative 'recipe'
require_relative 'item'
require 'dxruby'

icons = Image.load_tiles('gfx/icons.png', 388 / 24, 168 / 24)
item_db = ItemDB.new(Hash[*(%w(
  fire:0
  flame:0
  candle:0
  water:0
  water_pot:0
  gelatin:0
  air:0
  whirlwind:0
  fog:0
  stone:0
  stone_hummer:0
  stone_plate:0
  stone_axe:0
  mud:0
  coal:0
  oil:0
  cold:0
  ice_cube:0
  electricity:0
  thunder:0
  tree:0
  wood:0
  lumber:0
  wood_stick:0
  charcoal:0
  seed:0
  flower:0
  leaf_dew:0
  harb:0
  portion:0
  vine:0
  rope:0
  paper:0
  fine_paper:0
  cotton:0
  yarn:0
  cloth:0
  mushroom:0
  yeast:0
  grape:0
  wine:0
  vinegar:0
  rice:0
  meshi:0
  rock_salt:0
  salt:0
  salt_jar:0
  iron_ore:0
  iron:0
  iron_hummer:0
  fine_iron:0
  iron_stick:0
  knife:0
  steel_hummer:0
  copper_ore:0
  copper:0
  fine_copper:0
  copper_wheel:0
  silver_ore:0
  silver:0
  fine_silver:0
  silver_screw:0
  gold_ore:0
  gold:0
  fine_gold:0
  gold_gear:0
  chronoglass:0
  ruby:0
  sapphire:0
  emerald:0
  quartz:0
  celestite:0
  heliodor:0
  fire_juel:0
  aqua_juel:0
  wind_juel:0
  earth_juel:0
  ice_juel:0
  thunder_juel:0
  pyro_portion:0
  hydro_portion:0
  aero_portion:0
  geo_portion:0
  frost_portion:0
  electro_portion:0
  pyromancy:0
  hydromancy:0
  geomancy:0
  frigomancy:0
  electromancy:0
  vita:0
  fairy:0
  syake:0
  tuna:0
  salmon:0
  magro:0
  toro:0
).map.with_index {|data, i|
  name, score = data.split(':')
  [i+1, ItemData.new(name, score, icons[i])]
}).flatten])
ingredient = -> material, amount=1 { Ingredient.new(material, amount) }
recipes = Recipes.new(
  [
    [9, [ingredient[1], ingredient[4]]]
  ].map {|product, ingredients|
    Recipe.new(product, ingredients)
  }
)
class Media < Sprite
  attr_reader :item
  def initialize(x, y, item)
    @item = item
    super(x, y, @item.icon)
  end
end
media = []

[1, 4, 7, 10].each {|n|
  media.push Media.new(
    rand(Window.width-48)+24,
    rand(Window.height-48)+24,
    item_db[n]
  )
}
mouse = Sprite.new(0, 0)
mouse.collision = [0, 0]
grab = nil
Window.loop do
  mouse.x, mouse.y = Input.mouse_pos_x, Input.mouse_pos_y
  hit = mouse.check(media)
  if hit.empty?
    unless grab
      Input.set_cursor IDC_ARROW
    end
  else
    Input.set_cursor IDC_HAND
  end
  if Input.mouse_push?(M_LBUTTON)
    unless hit.empty?
      grab = hit.first
      grab.z = 100
      media.delete(hit.first)
    end
  elsif Input.mouse_down?(M_LBUTTON)
    if grab
      grab.x = mouse.x
      grab.y = mouse.y
    end
  elsif Input.mouse_release?(M_LBUTTON)
    if grab
      if hit.empty?
        grab.z = 0
        media.push grab
      else
        found = recipes.find(ingredient[grab.item.id], ingredient[hit.first.item.id])
        if found
          media.delete(hit.first)
          media.push(Media.new(
            mouse.x,
            mouse.y,
            item_db[found]
          ))
        else
          grab.z = 0
          media.push grab
        end
      end
      grab = nil
    end
  end
  Sprite.update(media)
  if grab
    grab.update 
    grab.draw
  end
  Sprite.draw(media)
end
