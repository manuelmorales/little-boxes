# LittleBoxes

This is a sample project to clone and use as a template for creating your own Ruby gems.
By default, the license is copyright attributed to Workshare ltd.
For open source projects, you can copy the LICENSE.txt from [MiniCheck](https://github.com/workshare/mini-check).


## Quick Start

Clone this repo and follow the "to-do":

```bash
git grep TODO
```

Create a repo on GitHub or ask Manuel to do it.
Once you have it, edit origin to point to it instead:

```bash
git remote rm origin
git remote add origin git@github.com:workshare/my-gem.git
git push -u origin master
```

Example of refatoring with the command line:

```bash
find -name \*my_class\* -exec rename 's/my_class/service_generator/' {} \;
find -name \*little_boxes\* -exec rename 's/little_boxes/mini_me/' {} \;
git add .
git commit -m "Renamed files"

git ls-files | xargs sed -i -e 's/LittleBoxes/MiniMe/g'
git ls-files | xargs sed -i -e 's/little_boxes/little_boxes/g'

git ls-files | xargs sed -i -e 's/MyClass/ServiceGenerator/g'
git ls-files | xargs sed -i -e 's/my_class/service_generator/g'

git add .
git commit -m "Renamed content"

rake # To make sure everything is OK
```




## Contributing

Do not forget to run the tests with:

```bash
rake
```

And bump the version with any of:

```bash
$ gem bump --version 1.1.1       # Bump the gem version to the given version number
$ gem bump --version major       # Bump the gem version to the next major level (e.g. 0.0.1 to 1.0.0)
$ gem bump --version minor       # Bump the gem version to the next minor level (e.g. 0.0.1 to 0.1.0)
$ gem bump --version patch       # Bump the gem version to the next patch level (e.g. 0.0.1 to 0.0.2)
```


## License

Copyright (c) 2014 [Workshare ltd](http://www.workshare.com).
