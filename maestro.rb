#!ruby
require 'delegate'
require_relative 'recipe'
require_relative 'item'
require 'dxruby'

def ingredients(item_db)
  -> a, b {[Ingredient.new(item_db[a].id), Ingredient.new(item_db[b].id)]}
end

def recipe(item_db)
  -> product, ingredients { Recipe.new(item_db[product].id, ingredients) }
end

class Medium < Sprite
  attr_reader :item
  def initialize(x, y, item)
    @item = item
    super(x, y, @item.icon)
  end
  def id
    @item.id
  end
  def self.pop(item)
    self.new(
      rand(Window.width-48)+24,
      rand(Window.height-48)+24,
      item
    )
  end
end

class Media < DelegateClass(Array)
  def initialize
    @_ = []
    super(@_)
  end
  def to_a
    @_
  end
  alias add push
  def renew(old, new)
    delete(old)
    push(new)
  end
  def update
    Sprite.update(@_)
  end
  def draw
    Sprite.draw(@_)
  end
end

class Alchemy
  def initialize(recipes, item_db)
    @recipes = recipes
    @item_db = item_db
  end
  def ingredient(material, amount=1)
    Ingredient.new(material.id, amount)
  end
  def find(a, b)
    (found = @recipes.find(ingredient(a), ingredient(b))) and @item_db[found]
  end
  def synthesize(a, b)
    Medium.new((a.x+b.x)/2, (a.y+b.y)/2, find(a, b))
  end
end

class Hand < Sprite
  attr_reader :grabbing
  def initialize
    self.x = 0
    self.y = 0
    self.collision = [0, 0]
    @grabbing = nil
  end
  def input_update
    self.x = Input.mouse_pos_x
    self.y = Input.mouse_pos_y
  end
  def update
    if Input.mouse_down?(M_LBUTTON)
      if grabbing?
        grabbing.x = self.x
        grabbing.y = self.y
      end
    end
    grabbing.update if grabbing?
  end
  def hit?(media)
    self.check(media.to_a).last.tap {|hit|
      if hit
        Input.set_cursor(IDC_HAND)
      else
        Input.set_cursor(IDC_ARROW) unless grabbing?
      end
    }
  end
  def grab(medium)
    @grabbing = medium
    self.collision = [0, 0, 32, 32]
    grabbing.z = 100
  end
  def grab?(media)
    Input.mouse_push?(M_LBUTTON) and hit?(media)
  end
  def release
    grabbing.z = 0
    self.collision = [0, 0]
    grabbing.tap { @grabbing = nil }
  end
  def release?
    Input.mouse_release?(M_LBUTTON) and grabbing?
  end
  def grabbing?
    grabbing != nil
  end
end

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

recipes = Recipes.new([
  [:fire, ingredients(item_db)[:stone, :iron_ore]],
  [:coal, ingredients(item_db)[:fire, :tree]]
].map {|product, ingredients| recipe(item_db)[product, ingredients]})

alchemy = Alchemy.new(recipes, item_db)
media = Media.new
[:stone, :iron_ore, :tree].each {|n| media.add(Medium.pop(item_db[n])) }

hand = Hand.new
grab = nil
Window.loop do
  hand.input_update
  hit = hand.hit?(media)
  if hand.grab?(media)
    hand.grab(media.delete(hit)) if hit
  elsif hand.release?
    if hit and alchemy.find(hand.grabbing, hit)
      media.add(alchemy.synthesize(media.delete(hit), hand.release))
    else
      media.add(hand.release)
    end
  end
  hand.update
  media.update
  hand.grabbing.draw if hand.grabbing?
  media.draw
end
