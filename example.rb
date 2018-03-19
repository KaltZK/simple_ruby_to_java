use :utils => ref(:Utils, :WTFClass)
let :a => 1
let :b => 2, :c => 3
println a + b
let :d => a + b

comment "Java comment."


helper :concat, [:String, :String], :String do |s1, s2|
    ret s1 + s2
end

let :ssr => concat("1", "2")

let :a => 1
let :h => -a
let :header => json_object
let :body   => json_object
let :query  => json_object
map_merge header, {'a' => 1, 'b' => 'b', 'c' => nil}

let :response => sendRequest!(header, query, response?).as(:ResponseMap)
let :imageId => response.json?._.imageList[0].id.as(:Integer)
let :list => new_object(:Array.t(:Map.t(:Integer, :String)))
println imageId