use :utils => ref(:Utils, :WTFClass)
let :a => 1
let :b => 2, :c => 3
println a + b
let :d => a + b

comment "Java comment."


let :a => 1
let :h => -a
let :header => json_object
let :body   => json_object
let :query  => json_object
load_json header, 'a' => 1, 'b' => 'b', 'c' => nil

let :response => sendRequest!(header, query, response?).as(:ResponseMap)
let :imageId => response.json?._.imageList[0].id.as(:Integer)

println imageId