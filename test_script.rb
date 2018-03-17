require './helpers'

class TSJsonPathAssest < TSValue
  def initialize(parent, path)
    @parent = parent
    @path = path
    super(:String, %Q{#{@parent.java}.getValue( "#{['$'].concat(path).join('.')}" )})
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

ns = TSNamespace.new
ns.run(File.read 'foo.rb')
puts ns.render