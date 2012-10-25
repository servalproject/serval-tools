Instructions for sp-mantis2github
=================================

The instructions below assume you are using Linux or another Unix-like
operating system with a Bourne shell (eg, [Bash][]).

I describe below how I used the **sp-mantis2github** script to migrate issues
from [Serval Project’s Mantis bug tracker][mantis] web site to the Serval
Project’s various GitHub repositories.  The examples given below should
generalise easily to other situations.

How to migrate a Mantis issue to GitHub
=======================================

To migrate the Serval Project issues, I first created a file called
`.mantis2github` in my home directory, having the following contents (passwords
and authorisation tokens have been obscured with `*****`):

    [mantis]
    url: http://developer.servalproject.org/mantis
    user: andrew
    password: *******
    [github]
    login: quixotique
    password: ********
    org: servalproject
    [github users]
    quixotique: ****************************************
    gardners: ****************************************
    lakeman: ****************************************
    timelady: ****************************************
    [user map]
    PaulGardnerStephen: gardners
    andrew: quixotique
    jeremy: lakeman
    romana: timelady

The two obscured `password:` lines actually contained the clear text of my
Mantis `andrew` user and GitHub `quixotique` user passwords respectively.  The
obscured lines in the `[github users]` section actually contained GitHub API
tokens, which can be obtained as described below, under *How to get
authorisation tokens from your users*.

That file contains sensitive information, so I protected it from being read by
any other users:

    chmod 600 $HOME/.mantis2github

(**sp-mantis2github** will refuse to read it unless it is protected like this.)
Then, for example, to migrate our [Mantis issue 128][] to [its GitHub
replacement][batphone#21], I issued the following command:

    sp-mantis2github migrate 128 batphone

This created a new GitHub issue in the batphone repository.  It then copied all
the information from Mantis issue 128 into the new GitHub issue, adding a
comment linking back to the original Mantis issue to show that the migration
was performed.  It then tagged the new GitHub issue with the mantis label, and
added a note to the original Mantis issue linking to the GitHub issue.
Finally, it closed the Mantis issue with the resolution “suspended”.

How it works
============

**sp-mantis2github** copies as much information as possible from the original
Mantis issue into its GitHub replacement: summary, description,
reproducibility, other information, notes, links to related issues,
attachments, time tracking, category, priority, severity, resolution, tags,
project name, platform, OS, and target/fixed-in OS versions.  Only a few of
these fit into GitHub’s very simple issue scheme, so most are simply quoted
into the issue description text.

One limitation is that the dates shown on GitHub issues and comments are the
dates that the migration was performed, not the original dates from Mantis.
There is no way around this, because the GitHub Issue API does not provide any
way to set the date/time of issue creation or comment creation; it always uses
the current time.  So **sp-mantis2github** adds a date/time prefix line to all
migrated texts.

Another limitation is that attachments are not fully migrated to GitHub.  At
present, GitHub does not support attachments.  This was the greatest
shortcoming that made us think twice about switching to GitHub.  There is a
work-around, but it will take some effort.  In the meantime, attachments from
migrated issues remain hosted on our Mantis site, and our migrated GitHub
issues simply link to them.

Preserving users from Mantis to GitHub
======================================

To make GitHub notify the right people as an issue progresses, the migrated
issue and its comments must be reported by the same people as made the original
Mantis reports.  This takes some doing.

The `[user map]` section of the **sp-mantis2github** configuration file
associates Mantis user names with GitHub login names, but by itself this is not
enough.  The `[github users]` section contains user authorisation tokens for
GitHub users, which allows it to impersonate those users when creating issues
and comments.  This requires some work and a great deal of trust on the part of
those users; each must use **sp-mantis2github** to generate a token and send it
to you securely (instructions are given below).

A GitHub token allows you to connect to GitHub with the user’s credentials, so
it is sensitive information that must be protected from theft, used
responsibly, and destroyed once no longer needed.  At the Serval Project, we
are a small team so this was not hard to arrange, even though some of us use
our own personal GitHub identities for project work.  For large organisations,
though, it could prove difficult.

If a user’s token is not available, **sp-mantis2github** will use your own
identity as the reporter, and add a prefix line to the issue or comment
referring to the original reporter, so all is not lost.

How to install sp-mantis2github
===============================

The [sp-mantis2github][] Python script was created by the [Serval Project][]
and is maintained in their [serval-tools][] GitHub repository.  It has been
tested using only [Python 2.7][].  It uses the Python [suds][] SOAP client
library to connect to Mantis, and the Python [PyGithub][] client library to
connect to GitHub.  It uses the Python [docopt][] library to parse and document
its command-line.

You will only need [suds][] if want to use **sp-mantis2github** to migrate
issues or query the Mantis server.  If you only want to perform GitHub
operations (eg, list issues or generate an authentication token) then you can
omit **suds**.  Most Linux distributions supply **python-suds** as an
installable software package, otherwise you can [fetch suds][] from [PyPI][]
using [pip][].

The latter two, [PyGithub][] and [docopt][], are included as [Git submodules][]
of serval-tools.

To download and set up serval-tools, you will need Git installed.  The
following commands will dowload and install serval-tools in the current working
directory:

    git clone git://github.com/servalproject/serval-tools.git
    cd serval-tools
    git submodule init
    git submodule update

Next, add the `serval-tools/bin` directory to your `PATH` environment variable
(this can be done in your `$HOME/.profile` file):

    export PATH="/.../serval-tools/bin:$PATH"

Finally, create the `$HOME/.mantis2github` configuration file as described
above, using your own Mantis and GitHub login names and passwords and GitHub
authorisation tokens for the users in your organisation.  (Tokens are
40-hex-digit numbers, shown obscured by `*****` in the sample config file
above.)

How to get authorisation tokens from your users
===============================================

To get authorisation tokens for users in your organisation, you should instruct
them to download and install serval-tools using the above instructions, then
execute the following commands (using the [Bash][] shell) to generate a token:

    echo '[github]' >~/.mantis2github
    chmod 0600 ~/.mantis2github
    echo 'login: yourGitHubLogin' >>~/.mantis2github
    echo 'password: yourGitHubPassword' >>~/.mantis2github
    ./bin/sp-mantis2github github register

Users can send their tokens to you using whatever medium you like, but bear in
mind that a token confers the power to impersonate its user on GitHub, so
should be protected from falling into the wrong hands.  In particular, do not
send tokens over Facebook or Twitter.

Insert your users’ GitHub logins and tokens into your own `.mantis2github`
configuration file, in the `[github users]` section.

After generating their tokens, users should delete their `.mantis2github`
config file:

    rm ~/.mantis2github

Some background
===============

At the [Serval Project][] in 2012 we decided to move our issue tracking from
[Mantis][] to Github Issues.  Mantis, although powerful, has an unappealing and
difficult user interface that makes it a chore to use, so our issues were being
routinely neglected.  We experimented with GitHub Issues, and found that its
modern, clean, well designed user interface made it a pleasure to report and
advance issues.

We had a couple of hundred issues registered in [our Mantis server][mantis],
about half of which were still open and relevant.  We needed a way to automate
the migration of these issues to [our various GitHub repositories][github],
preserving as much information as possible.

I searched for tools to do the job, but found nothing suitable.  My search
results were dominated by a GitHub plugin for Mantis which scrapes issue
references from GitHub commit comments, and unfortunately is unrelated to what
I wanted.

The closest tool I found was [Mantis-Issues-Ext][], a Safari extension written
by David Linsin to scrape data from a Mantis bug view page and paste it into a
GitHub Issue.  Apart from its dependence on Safari, it did not handle
attachments, relationships, inter-Mantis-issue references, tags or notes.

So I developed the [sp-mantis2github][] program, and made it available to the
world at large.  Like all the software we develop at the Serval Project, it is
licensed to the public under the terms of the [GNU General Public License
version 2][GPL2].

To see **sp-mantis2github** in action, just look at [some of the issues we have
migrated][batphone issues].

Conclusion and future work
==========================

The **sp-mantis2github** script has several limitations that inevitably arise
from the very different data schemes used by Mantis and GitHub Issues.  But
there are other limitations that could be overcome with more development work:

* Can only migrate to repositories in a GitHub organisation (not user
  repositories).
* Only migrates a single issue per invocation.
* Does not migrate attachments themselves, just links to the Mantis
  attachments, so Mantis has to remain available to keep attachments available.
* Does not handle “parent of”, “child of”, “duplicate of” and “has duplicate”
  relationships between Mantis issues.
* No way to configure a default target repository.
* Only tested with [Python 2.7][] on Linux.
* Incomplete documentation.

Despite these shortcomings, I hope it proves useful to others.  Please let me
know about your experience using **sp-mantis2github**.

Andrew Bettison <andrew@servalproject.org>


[Serval Project]: http://www.servalproject.org
[Mantis]: http://www.mantisbt.org
[GitHub Issues]: https://github.com/blog/831-issues-2-0-the-next-generation
[sp-mantis2github]: https://github.com/servalproject/serval-tools/blob/master/bin/sp-mantis2github
[serval-tools]: https://github.com/servalproject/serval-tools
[mantis]: http://developer.servalproject.org/mantis/view_all_bug_page.php
[batphone issues]: https://github.com/servalproject/batphone/issues?labels=mantis
[Python 2.7]: http://www.python.org/download/releases/2.7
[GPL2]: http://www.gnu.org/licenses/gpl-2.0.html
[suds]: https://fedorahosted.org/suds
[PyPI]: http://pypi.python.org/pypi
[pip]: http://www.pip-installer.org/en/latest/index.html
[fetch suds]: http://pypi.python.org/pypi/suds
[PyGithub]: https://github.com/jacquev6/PyGithub
[docopt]: https://github.com/docopt/docopt
[Git submodules]: http://git-scm.com/book/en/Git-Tools-Submodules
[Bash]: http://en.wikipedia.org/wiki/Bash_(Unix_shell)
[Mantis-Issues-Ext]: https://github.com/dlinsin/Mantis-Issues-Ext
[Mantis issue 128]: http://developer.servalproject.org/mantis/view.php?id=128
[batphone#21]: https://github.com/servalproject/batphone/issues/21
