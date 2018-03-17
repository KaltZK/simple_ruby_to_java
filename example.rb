use :utils => ref(:Utils, :WTFClass)
let :a => 1
let :b => 2, :c => 3
println a + b
let :d => a + b

comment "Java comment."

println d
println utils

if_true a == b do
  let :x => 1
  let :x => x + x.doSomeShit!(233) # call method
  let :z => x.whatTheFuck? # get attribute
end

let :value => a.json?._.a.b.c.d[3].a

let :d => 4