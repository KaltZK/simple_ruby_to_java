require './helpers'

class TSJsonPathAssest < TSValue
  def initialize(parent, path)
    @parent = parent
    @path = path
    super(:Object, %Q{JsonPathUtil.getJsonPathValue( #{@parent.java},  "#{['$'].concat(path).join('.')}" )})
  end
  def [](idx)
    np = @path.clone
    np.last.concat("[#{idx}]")
    TSJsonPathAssest.new(@parent, np)
  end
  def method_missing(nm, *args)
    if args.empty?
      TSJsonPathAssest.new(@parent, @path + [nm.to_s])
    else
      super(nm, *args)
    end
  end
  def _
    TSJsonPathAssest.new(@parent, @path + [''])
  end
end

class TSValue
  def json?
    TSJsonPathAssest.new(self, [])
  end
end

class TestExprEnv < TSExprEnv
  def json_object()
    TSValue.new(:JSONObject, "new JSONObject()")
  end
end

class TestStatEnv < TSStatEnv
  def map_merge(var, data)
    data.each do |k, v|
      statement "#{var.java}.put(#{k.tsvalue.java}, #{v.tsvalue.java});"
    end
  end
end

if __FILE__ == $0
  ns = TSNamespace.new(TestExprEnv, TestStatEnv)
  ns.run(File.read ARGV[0])
  puts ns.render
end