getting shit to work
====================

if you haphazardly try random things and get it to work, please take 
some extra time to clean up and minimize your changes.  we tend to copy 
changes from ctc to ctc so it becomes a big mess with the frequency that 
aldebaran change things.

we have plans to move to qibuild when we drop support for ctc 2.1, so 
that should reduce the amount of cmake code that needs to be written.

for 2.1 and earlier, everything should compile against cross-compiled 
libraries, so that tools like offnao and vatnao running on your computer 
work exactly the same as runswift running on the robot

for 2.8 and later, only runswift and libagent should compile with the 
ctc.  the tools should interact with runswift in such a way that 
everything is running in the runswift executable.  in this way, we 
aren't tied to a specific version of framework, compiler, or even 
language.  offnao & vatnao should not link against libsoccer!!!

style
=====

CMake supports putting notes in the `else` and `endif` statements.  
don't use them for else, but leave a comment so we know the 
corresponding `if`.  your resulting statement should look like:

```
if(condition)
   ...
else() # not condition
  ...
endif(condition)
```
