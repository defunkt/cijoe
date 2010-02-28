CI Joe
======

Joe is a [Continuous
Integration](http://en.wikipedia.org/wiki/Continuous_integration)
server that'll run your tests on demand and report their pass/fail status.

Because knowing is half the battle.

![The Battle](http://img.skitch.com/20090805-g4a2qhttwij8n2jr9t552efn3k.png)

Quickstart
----------

Rip:

    $ rip install git://github.com/defunkt/cijoe.git
    $ git clone git://github.com/you/yourrepo.git
    $ cijoe yourrepo

Gemcutter:

    $ gem install cijoe
    $ git clone git://github.com/you/yourrepo.git
    $ cijoe yourrepo

Boom. Navigate to http://localhost:4567 to see Joe in action.
Check `cijoe -h` for other options.

Basically you need to run `cijoe` and hand it the path to a git
repo. Make sure this isn't a shared repo: Joe needs to own it.

Joe looks for various git config settings in the repo you hand it. For
instance, you can tell Joe what command to run by setting
`cijoe.runner`:

    $ git config --add cijoe.runner "rake -s test:units"

Joe doesn't care about Ruby, Python, or whatever. As long as the
runner returns a non-zero exit status on fail and a zero on success,
everyone is happy.

Need to do some massaging of your repo before the tests run, like
maybe swapping in a new database.yml? No problem - Joe will try to
run `.git/hooks/after-reset` if it exists before each build phase.
Do it in there. Just make sure it's executable.

Want to notify IRC or email on test pass or failure? Joe will run
`.git/hooks/build-failed` or `.git/hooks/build-worked` if they exist
and are executable on build pass / fail. They're just shell scripts -
put whatever you want in there.

Tip: your repo's `HEAD` will point to the commit used to run the
build. Pull any metadata you want out of that scro.


Other Branches
--------------

Want joe to run against a branch other than `master`? No problem:

    $ git config --add cijoe.branch deploy


Campfire
--------

Campfire notification is included, because it's what we use. Want Joe
notify your Campfire? Put this in your repo's `.git/config`:

    [campfire]
    	user = your@campfire.email
    	pass = passw0rd
    	subdomain = whatever
    	room = Awesomeness
    	ssl = false

Or do it the old fashion way:

    $ cd yourrepo
    $ git config --add campfire.user chris@ozmm.org
    $ git config --add campfire.subdomain github
    etc.


Checkin' Status
---------------

Want to see how your build's doing without any of this fancy UI crap?
Ping Joe for the lowdown:

    curl http://localhost:4567/ping

Joe will return `200 OK` if all is quiet on the Western Front. If
Joe's busy building or your last build failed, you'll get `412
PRECONDITION FAILED`.

Multiple Projects
-----------------

Want CI for multiple projects? Just start multiple instances of Joe!
He can run on any port - try `cijoe -h` for more options.


HTTP Auth
---------

Worried about people triggering your builds? Setup HTTP auth:

    $ git config --add cijoe.user chris
    $ git config --add cijoe.pass secret


GitHub Integration
------------------

Any POST to Joe will trigger a build. If you are hiding Joe behind
HTTP auth, that's okay - GitHub knows how to authenticate properly.

![Post-Receive URL](http://img.skitch.com/20090806-d2bxrk733gqu8m11tf4kyir5d8.png)

You can find the Post-Receive option under the 'Service Hooks' subtab
of your project's "Admin" tab.


Daemonize
---------

Want to run Joe as a daemon? Use `nohup`:

    $ nohup cijoe -p 4444 repo &


Other CI Servers
----------------

Need more features? More notifiers? Check out one of these bad boys:

* [Cerberus](http://cerberus.rubyforge.org/)
* [Integrity](http://integrityapp.com/)
* [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com/)
* [BuildBot](http://buildbot.net/trac)


Screenshots
-----------

![Building](http://img.skitch.com/20090806-ryw34ksi5ixnrdwxcptqy28iy7.png)

![Built](http://img.skitch.com/20090806-f7j3r65yecaq13hdcxqwtc5krd.)


Questions? Concerns?
--------------------

[Issues](http://github.com/defunkt/cijoe/issues) or [the mailing list](http://groups.google.com/group/cijoe).


( Chris Wanstrath :: chris@ozmm.org )
