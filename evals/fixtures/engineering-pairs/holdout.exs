ExUnit.start()
defmodule MoreHidden do
 use ExUnit.Case
 test "historical semantics" do
   base=[{13,:posted,true,:none},{-4,:posted,true,:imported},{-2,:posted,true,:reversed},{0,:posted,true,:recorded},{3,:posted,false,:none},{10,:waived,true,:none},{18,:posted,true,:none}]
   want=[{13,:waived,true,:none},{-4,:posted,true,:imported},{-2,:posted,true,:reversed},{0,:posted,true,:recorded},{3,:posted,false,:none},{10,:waived,true,:none},{18,:waived,true,:none}]
   assert Runner.run(base,2)=={want,3}
   assert Runner.run(want,2)=={want,2}
   assert Runner.run([],1)=={[],0}
 end
end
