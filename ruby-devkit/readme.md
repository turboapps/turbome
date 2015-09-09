Ruby for Windows including Development Kit 
==========================================
See http://www.rubyinstaller.org/ and https://github.com/oneclick/rubyinstaller/wiki/Development-Kit

It installs to `C:\rubydevkit472`

Build and launch the container

```
turbo build -n=ruby-devkit:2.1.3 turbo.it
turbo run ruby-devkit:2.1.3
```

Confirm your Ruby environment is correctly using the DevKit by running `gem install json --platform=ruby`. 

JSON should install correctly and you should see with native extensions in the screen messages. 

Next run `ruby -rubygems -e "require 'json'; puts JSON.load('[42]').inspect"` to confirm that the json gem is working.

