# Drivy Backend Challenge

You can use ./test_all_levels.sh (after running sudo chmod +x test_all_levels.sh) to check the results of all levels together.
For each level, output and expected_output are compared using a unit test, and output is generated.

### test_all_levels.sh contents
cd level1  
ruby test.rb  
ruby main.rb  
cd ../level2  
ruby test.rb  
ruby main.rb  
cd ../level3  
ruby test.rb  
ruby main.rb  
cd ../level4  
ruby test.rb  
ruby main.rb  
cd ../level5  
ruby test.rb  
ruby main.rb

### Expected result for every level (x = 1, 2, 3, 4, 5)
Loaded suite test<br />
Started<br />
==================================================================================================<br />
 Level x<br />
==================================================================================================<br />
+++++++++++++++++++++++++++++++++++++++++++++++++<br />
++++++++++++ Level x : tests  ++++++++++++<br />
+++++++++++++++++++++++++++++++++++++++++++++++++<br />
.<br />

Finished in 0.002386152 seconds.<br />
--------------------------------------------------------------------------------------------------------------------------------------------------------------<br />
1 tests, 1 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications<br />
100% passed<br />
--------------------------------------------------------------------------------------------------------------------------------------------------------------<br />
419.08 tests/s, 419.08 assertions/s<br />
*******************************************************<br />
************* Level x : output generated **************<br />
*******************************************************<br />
==================================================================================================<br />
