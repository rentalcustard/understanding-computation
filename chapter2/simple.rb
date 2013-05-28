class Expression
  def in_environment(environment)
    @environment = environment
    self
  end

  attr_reader :environment

  def inspect
    "<<#{self}>>"
  end
end

class ValueExpression < Expression
  def initialize(value)
    @value = value
  end

  attr_reader :value

  def to_s
    value.to_s
  end

  def reduce
    self
  end
end

class BinaryExpression < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  attr_reader :left, :right

  def reduce
    perform_operation(left.in_environment(@environment), right.in_environment(@environment))
  end

  def +(other)
    reduce + other
  end

  def *(other)
    reduce * other
  end

  def <(other)
    reduce < other
  end
end

class Number < ValueExpression
  def +(other)
    Number.new(value + other.reduce.value)
  end

  def *(other)
    Number.new(value * other.reduce.value)
  end

  def <(other)
    value < other.reduce.value
  end
end

class Add < BinaryExpression
  def to_s
    "#{left} + #{right}"
  end

  def perform_operation(left, right)
    left + right
  end
end

class Multiply < BinaryExpression
  def to_s
    "#{left} * #{right}"
  end

  def perform_operation(left, right)
    left * right
  end
end

class Boolean < ValueExpression
end

class LessThan < BinaryExpression
  def to_s
    value.to_s
  end

  def perform_operation(left, right)
    Boolean.new(left < right)
  end
end

class Variable < Expression
  def initialize(name)
    @name = name
  end

  attr_reader :name

  def to_s
    name.to_s
  end

  def reduce
    @environment[name]
  end

  def +(other)
    reduce + other
  end

  def *(other)
    reduce * other
  end
end

class DoNothing < Expression
  def to_s
    'do-nothing'
  end

  def reduce
    self
  end
end

class Assign < Expression
  def initialize(name, expression)
    @name = name
    @expression = expression
  end

  attr_reader :name, :expression

  def to_s
    "#{name} := #{expression}"
  end

  def reduce
    @environment[name] = expression.in_environment(@environment).reduce
    DoNothing.new.in_environment(@environment)
  end
end

class If < Expression
  def initialize(condition, consequence, alternative)
    @condition = condition
    @consequence = consequence
    @alternative = alternative
  end

  attr_reader :condition, :consequence, :alternative

  def to_s
    "if ( #{condition} ) { #{consequence} } else { #{alternative} }"
  end

  def reduce
    case condition.in_environment(@environment).reduce
    when Boolean.new(true)
      consequence.in_environment(@environment).reduce
    else
      alternative.in_environment(@environment).reduce
    end
  end
end

class Machine < Struct.new(:expression, :environment)
  def run
    expression.in_environment(environment).reduce
  end
end
