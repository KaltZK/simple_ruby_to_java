use :utils => ref(:Utils, :T)
let :a => 1
let :b => 2
println a + b
let :d => a + b

println d
println utils

if_true a == b do
  let :x => 1
  let :x => x + x.doSomeShit!
end

let :path => a.json?._.a.b.c.d[3].a

let :d => 4