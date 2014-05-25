#!ruby
require 'forwardable'

class Recipes
  extend Forwardable
  def_delegators :@recipes, :[]
  def initialize(recipes=[])
    @recipes = recipes
  end
  def find(*ingredients)
    found = self.match(*ingredients) and found.product
  end
  def match(*ingredients)
    @recipes.find {|recipe| recipe.match(*ingredients) }
  end
end

class Ingredient
  include Comparable
  attr_reader :material
  attr_reader :amount
  def initialize(material, amount=1)
    @material = material
    @amount = amount
  end
  def <=>(objective)
    case self.material <=> objective.material
    when -1 then -1
    when  0 then self.amount <=> objective.amount
    when  1 then  1
    end
  end
end

class Recipe
  attr_reader :product
  attr_reader :ingredients
  def initialize(product, ingredients=[])
    @product = product
    @ingredients = ingredients
  end
  def match(*ingredients)
    self.ingredients.sort == ingredients.sort
  end
end
