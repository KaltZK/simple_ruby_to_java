NoExprError = Class.new NoMethodError
VarExistsError = Class.new RuntimeError

class TSEnv
  def method_missing(nm, *args)
    raise NoExprError.new("Undefined expression `#{nm}' for #{self}")
  end
end

class TSNamespace
  attr_accessor :expr_env, :stat_env, :parent
  def initialize(expr_env_class = TSExprEnv, stat_env_class = TSStatEnv, parent = nil)
    @variables = {}
    @stat_list = []
    @expr_env_class = expr_env_class
    @stat_env_class = stat_env_class
    @expr_env = expr_env_class.new(self)
    @stat_env = stat_env_class.new(self)
    @parent = parent
  end

  def create_subnamespace()
    TSNamespace.new(
      @expr_env_class,
      @stat_env_class,
      self
    )
  end

  def run(code)
    @runtime = TSRuntime.new(self, @expr_env, @stat_env)
    if code.is_a?(Proc)
      @runtime.instance_eval(&code)
    else
      @runtime.instance_eval(code)
    end
  end

  def add_statement(stat)
    @stat_list.push(stat)
  end

  def refer(nm, val)
    raise VarExistsError.new("Variable `#{nm}' trying to convert #{@variables[nm].type} => #{val.type} at #{self}") if @variables[nm] && @variables[nm].type != val.type
    if /^[A-Z]/ === nm.to_s
      @runtime.const_set nm, val
    end
    @variables[nm] = val
  end

  def register(nm, val)
    refer(nm, TSVar.new(nm, val))
  end

  def _get_var(nm)
    @variables[nm] || (@parent&._get_var(nm))
  end

  def _has_var?(nm)
    @variables.has_key?(nm) ||
      (@parent&._has_var? nm)
  end

  def render(step_indent = 4, indent = 0)
    list = @stat_list.map do |stat|
      stat.is_a?(TSNamespace) ?
        stat.render(step_indent, indent + step_indent) : (" "*indent + stat)
    end
  end

  def result(step_indent = 4, indent = 0)
    render(step_indent, indent).flatten.join("\n")
  end
end

class TSRuntime
  def initialize(namespace, expr_env, stat_env)
    @namespace = namespace
    @expr_env = expr_env
    @stat_env = stat_env
  end

  def method_missing(nm, *args, &block)
    args.map!(&:tsvalue)
    if args.empty? && @namespace._has_var?(nm)
      return @namespace._get_var(nm)
    else
      begin
        @expr_env.send(nm, *args, &block)
      rescue NoExprError => err
        begin
          @stat_env.send(nm, *args, &block)
        rescue NoExprError => err
          super(nm, *args)
        end
      end
    end

  end
end

class TSValue < TSEnv
  attr_reader :val, :type
  def initialize(type, str, val = nil)
    @val = val
    @str = str
    @type = type
    __init_operators
  end

  def java()
    @str
  end

  def tsvalue
    self
  end

  def method_missing(nm, *args)
    if /^(\w+)!$/ === nm.to_s
      TSValue.new(@type, "#{java}.#{$1}(#{args.map{|o| o.tsvalue.java}.join(", ")})")
    elsif /^(\w+)\?$/ === nm.to_s && args.empty?
      TSValue.new(@type, "#{java}.#{$1}")
    else
      super(nm, *args)
    end
  end

  def __init_operators
    %w{+ - * / ^ % & | && || < > ? :}.map(&:to_sym).each do |nm|
      define_singleton_method(nm) do |other|
        other = other.tsvalue
        TSValue.new(@type, "#{java} #{nm} #{other.java}")
      end
    end
    %w{! ~ -}.each do |nm|
      define_singleton_method(:"#{nm}@") do
        other = other.tsvalue
        TSValue.new(@type, "#{nm}#{java}")
      end
    end
    define_singleton_method( :== ) do |other|
      other = other.tsvalue
      TSValue.new(@type, "#{java}.equals( #{other.java} )")
    end
  end
end

class TSVar < TSValue
  def initialize(name, val)
    @name = name
    super(val.type, val.java, val.val)
  end
  def java()
    @name.to_s
  end
end

class TSInnerObject < TSEnv
  def method_missing(nm, *args)
    case nm.to_s
    when /^(\w+)!$/
      s = "#{$1}( #{args.map(&:java).join(', ')} )"
      TSValue.new(:Object, s)
    when /^(\w+)\?$/
      if args.empty?
        TSValue.new(:Object, $1)
      else
        super(nm, *args)
      end
    else
      super(nm, *args)
    end
  end
end

class TSExprEnv < TSInnerObject
  def initialize(namespace)
    @namespace = namespace
  end

  def this()
    TSVar.new("this", TSValue.new(:Object, "this"))
  end

  def ref(name, type)
    TSVar.new(name, TSValue.new(type, name.to_s))
  end

  
end

class TSStatEnv < TSInnerObject
  def initialize(namespace)
    @namespace = namespace
  end
  
  def statement(stat)
    @namespace.add_statement(stat)
  end
  
  def run(*exprs)
    exprs.each do |e|
      statement e.java
    end
  end
  alias _ run

  def use(vars)
    vars.each do |nm, val|
      raise TypeError.new("Var `#{nm}' is not a TSValue: #{val}'") unless val.is_a?(TSValue)
      @namespace.refer(nm, val)
    end
  end

  def let(vars)
    vars.each do |nm, val|
      val = val.tsvalue
      if @namespace._has_var?(nm)
        statement "#{nm} = #{val.java} ;"
      else
        statement "#{val.type} #{nm} = #{val.java} ;"
      end
      @namespace.register(nm, val)
    end
  end

  def comment(str)
    statement "// #{str}"
  end

  def println(*vals)
    vals.each do |v|
      statement "System.out.println( #{v.java} );"
    end
  end

  def if_true(expr, &block)
    statement "if( #{expr.java} ){"
    sub = @namespace.create_subnamespace
    sub.run(block)
    statement sub
    statement "}"
  end

  def method_missing(nm, *args)
    statement "#{nm.to_s}( #{args.map(&:java).join(', ')} );"
  end

end

class Object
  def tsvalue
    raise RuntimeError.new("method `tsvalue' not defined for #{self}")
  end
end

class String
  def tsvalue
    TSValue.new(:String, inspect, self)
  end
end

class Fixnum
  def tsvalue
    TSValue.new(:Integer, inspect, self)
  end
end

class Float
  def tsvalue
    TSValue.new(:Double, inspect, self)
  end
end

class NilClass
  def tsvalue
    TSValue.new(:Object, "null", self)
  end
end

class TrueClass
  def tsvalue
    TSValue.new(:Boolean, "true", self)
  end
end

class FalseClass
  def tsvalue
    TSValue.new(:Boolean, "false", self)
  end
end

class Hash
  def tsvalue
    map do |k, v|
      [k, v.tsvalue]
    end.to_h
  end
end

class Array
  def tsvalue
    map(&:tsvalue)
  end
end

class Symbol
  def tsvalue
    self
  end
end