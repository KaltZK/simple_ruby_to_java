```ruby
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
```

```bash
ruby test_script.rb example.rb
```

```java
Integer a = 1 ;
Integer b = 2 ;
Integer c = 3 ;
System.out.println( a + b );
Integer d = a + b ;
// Java comment.
System.out.println( d );
System.out.println( Utils );
if( a.equals( b ) ){
    Integer x = 1 ;
    x = x + x.doSomeShit(233) ;
    Integer z = x.whatTheFuck ;
}
String value = a.getValue( "$..a.b.c.d[3].a" ) ;
```