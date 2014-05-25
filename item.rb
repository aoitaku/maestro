#!ruby
require 'delegate'

class ItemData
  attr_reader :name
  attr_reader :score
  attr_reader :icon
  def initialize(name, score, icon)
    @name = name
    @score = score
    @icon = icon
  end
end

class Item < DelegateClass(ItemData)
  attr_reader :id
  def initialize(data={})
    @id, data = data.to_a.first
    super(data)
  end
  def inspect
    "#<Item:#{'0x%014x' % self.object_id} @id=#{@id}, @data=#{super}>"
  end
end

class ItemDB < DelegateClass(Hash)
  def initialize(data)
    super(data)
  end
  def [](index)
    super(index) ? Item.new({index => super(index)}) : nil
  end
  def inspect
    "#<ItemDB:#{'0x%014x' % self.object_id} #{super}>"
  end
end
