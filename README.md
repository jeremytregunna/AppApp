#AppApp
AppApp is the first __completely native__ iOS client for ADN. We hope you love it as much as we do. For announcements follow [@appapp](http://alpha.app.net/appapp) on App.net.

## Important
The AppApp team decided to keep the code base open for the public. However, due to the nation of the stuff we are doing, we had to make a decision to start keeping some parts private / available only for the core team.

The primary reason for this: Advanced services like integrating __Apple Push Notifications__ require credentials, certificates and other things, that must not be made available publicly.

We have started to move those parts of our code base to a __Git submodule__ which will only be available for the core team.

However, we do include a compiled version of these parts as a static library, ready for you to compile and run. We've also configured the Xcode project so that you can leverage the Themes to enable the use of the static library or – if you are a member of the core team – build with source.

### Core Contributors
In order to check out the complete AppApp code base including the __Confidentials__:

1. Clone the publicly available code: `git clone git@github.com:sneakyness/AppApp.git`
2. CD into the project root: `cd AppApp`
3. Get the confidential sources folder: `git submodule update -i --recursive`

Notes:
* For step 3 you need to be a member of the core team. Ping [@ralf](http://alpha.app.net/ralf) if you need assistance.

We are confident, that this procedure will balance both our requirements and supporting the public with a jump start into App.net development.

If you make changes __to the submodule__, please keep in mind that you have to follow these steps in this exact order:

1. Run `build.sh` in the submodule's folder. This will build the static library.
2. Add, commit and push the submodule upstream.
3. Add, commit and push the super project (AppApp.git) upstream. 

## License
The AppApp source code is distributed under the __The MIT License (MIT)__ license.

_Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman_

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

Any end-user product or application build based on this code, must include the following acknowledgment: "This product includes software developed by the original AppApp team and its contributors", in the software itself, including a link to www.app-app.net.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Get in touch with the AppApp devs

* Nick Pannuto ([@sneakyness](http://alpha.app.net/sneakyness) on app.net, @ataraxia_status on twitter, [email](mailto:sneakyness@sneakyness.com))
* Brandon Sneed ([@bsneed](http://alpha.app.net/bsneed) on app.net and twitter, [email](mailto:brandon@redf.net))
* Vince Speelman ([@vinspee](http://alpha.app.net/vinspee) on app.net and twitter, [email](mailto:v@vinspee.me))
* Matt Herzog ([@protozog](http://alpha.app.net/protozog) on app.net and twitter, [email](mailto:protozog@gmail.com))
* Johnnie Pittman ([@jedi](http://alpha.app.net/jedi) on app.net, @dtjedi on twitter, [email](mailto:jpittman@group6.net))
* Travis Choma ([@tc](http://alpha.app.net/@tc) on app.net, @travischoma, [email](mailto:travischoma@gmail.com))
* Ralf Rottmann ([@ralf](http://alpha.app.net/ralf) on app.net, [@ralf](http://twitter.com/ralf) on Twitter)
* Jeremy Tregunna ([@jtregunna](http://alpha.app.net/jtregunna) on app.net, [@jtregunna](http://twitter.com/jtregunna) on Twitter)

You can find us in the [App.net hipchat](https://www.hipchat.com/garqCaGOZ), on irc.freenode.net in #appnet. You can also buy us beer in person, if you come to Seattle, Portland, Detroit, or San Francisco.

### What the font?

[It's Ubuntu.](http://font.ubuntu.com)
